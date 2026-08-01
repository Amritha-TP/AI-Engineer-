"""
Grad-CAM (Gradient-Weighted Class Activation Mapping) Generator for CIFAR-10 Model.
Provides explainable AI (XAI) visual heatmaps for CNN predictions.
"""

import os
import numpy as np
from PIL import Image
import tensorflow as tf


def generate_gradcam(
    model: tf.keras.Model,
    img_array: np.ndarray,
    original_img_path: str,
    output_heatmap_path: str,
    layer_name: str = None,
    pred_index: int = None,
) -> str:
    """
    Generate a Grad-CAM heatmap overlay image and save it.

    Args:
        model (tf.keras.Model): Trained Keras model.
        img_array (np.ndarray): Normalized input array of shape (1, 32, 32, 3).
        original_img_path (str): Path to original image file.
        output_heatmap_path (str): Destination path to save Grad-CAM overlay image.
        layer_name (str, optional): Name of conv layer to target. Defaults to last Conv2D layer.
        pred_index (int, optional): Index of class to compute Grad-CAM for. Defaults to top prediction.

    Returns:
        str: Path to saved Grad-CAM image file.
    """
    try:
        # Find target conv layer if not specified
        if layer_name is None:
            for layer in reversed(model.layers):
                if isinstance(layer, tf.keras.layers.Conv2D):
                    layer_name = layer.name
                    break

        if not layer_name:
            return ""

        # Construct a sub-model that outputs both the target layer feature maps and final predictions
        grad_model = tf.keras.models.Model(
            inputs=[model.inputs],
            outputs=[model.get_layer(layer_name).output, model.output],
        )

        with tf.GradientTape() as tape:
            conv_outputs, predictions = grad_model(img_array)
            if pred_index is None:
                pred_index = tf.argmax(predictions[0])
            class_channel = predictions[:, pred_index]

        # Extract gradients of target class w.r.t features of conv layer
        grads = tape.gradient(class_channel, conv_outputs)

        # Compute mean intensity of gradients per feature map channel
        pooled_grads = tf.reduce_mean(grads, axis=(0, 1, 2))

        # Weight conv layer output by pooled gradients
        conv_outputs = conv_outputs[0]
        heatmap = conv_outputs @ pooled_grads[..., tf.newaxis]
        heatmap = tf.squeeze(heatmap)

        # Apply ReLU to retain positive influences only and normalize [0, 1]
        heatmap = tf.maximum(heatmap, 0) / (tf.reduce_max(heatmap) + 1e-10)
        heatmap_np = heatmap.numpy()

        # Load original image and resize heatmap to match original dimensions
        orig_img = Image.open(original_img_path).convert("RGB")
        img_w, img_h = orig_img.size

        # Resize heatmap array to image dimensions
        heatmap_img = Image.fromarray(np.uint8(255 * heatmap_np)).resize(
            (img_w, img_h), Image.Resampling.BILINEAR
        )

        # Generate colored heatmap using custom jet color map manually (without matplotlib dependence)
        heatmap_arr = np.asarray(heatmap_img, dtype=np.float32) / 255.0

        # Simple JET colormap computation (Red/Yellow for high activation, Blue/Cyan for low)
        r = np.clip(1.5 - np.abs(heatmap_arr * 4 - 3), 0, 1)
        g = np.clip(1.5 - np.abs(heatmap_arr * 4 - 2), 0, 1)
        b = np.clip(1.5 - np.abs(heatmap_arr * 4 - 1), 0, 1)

        colored_heatmap = np.stack([r, g, b], axis=-1) * 255.0
        colored_heatmap_img = Image.fromarray(colored_heatmap.astype(np.uint8))

        # Blend original image (70%) with Grad-CAM heatmap (30%)
        blended = Image.blend(orig_img, colored_heatmap_img, alpha=0.45)

        # Ensure directory exists and save output file
        os.makedirs(os.path.dirname(output_heatmap_path), exist_ok=True)
        blended.save(output_heatmap_path)

        return output_heatmap_path
    except Exception as e:
        # Fallback if Grad-CAM fails
        print(f"Grad-CAM generation failed: {e}")
        return ""
