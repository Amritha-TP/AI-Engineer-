"""
CIFAR-10 Model Predictor Singleton.
Handles loading the Keras model once at application start, thread-safe inference,
probability parsing, Top-3 prediction extraction, and Grad-CAM integration.
"""

import json
import os
import threading
from typing import Any, Dict, List, Tuple
import numpy as np
from PIL import Image
import tensorflow as tf

from utils.gradcam import generate_gradcam
from utils.preprocess import preprocess_image


class CIFAR10Predictor:
    """
    Singleton class to manage CIFAR-10 model loading and prediction inference.
    Ensures model is loaded into memory exactly ONCE when Flask starts.
    """

    _instance = None
    _lock = threading.Lock()

    def __new__(cls, model_path: str = None, class_map_path: str = None):
        with cls._lock:
            if cls._instance is None:
                cls._instance = super(CIFAR10Predictor, cls).__new__(cls)
                cls._instance._initialized = False
            return cls._instance

    def __init__(
        self,
        model_path: str = "model/cifar10_model.h5",
        class_map_path: str = "model/class_names.json",
    ):
        if self._initialized:
            return

        self.model_path = model_path
        self.class_map_path = class_map_path
        self.model = None
        self.class_names = [
            "Airplane",
            "Automobile",
            "Bird",
            "Cat",
            "Deer",
            "Dog",
            "Frog",
            "Horse",
            "Ship",
            "Truck",
        ]

        self._load_model_and_metadata()
        self._initialized = True

    def _load_model_and_metadata(self):
        """
        Load Keras model binary and class names mapping file.
        """
        print(f"[INFO] Initializing CIFAR-10 Predictor...")

        # Load Class Mapping JSON if available
        if os.path.exists(self.class_map_path):
            try:
                with open(self.class_map_path, "r") as f:
                    self.class_names = json.load(f)
                print(f"[INFO] Loaded class map: {self.class_names}")
            except Exception as e:
                print(f"[WARNING] Could not parse class map JSON: {e}")

        # Load Keras Model
        if os.path.exists(self.model_path):
            try:
                self.model = tf.keras.models.load_model(self.model_path)
                print(f"[SUCCESS] Loaded Keras model from '{self.model_path}' successfully!")
            except Exception as e:
                print(f"[ERROR] Failed to load model from '{self.model_path}': {e}")
                self.model = None
        else:
            print(f"[WARNING] Model file '{self.model_path}' not found!")
            self.model = None

    def predict(
        self,
        image_input: Any,
        original_img_path: str = None,
        generate_gradcam_vis: bool = True,
    ) -> Dict[str, Any]:
        """
        Predict CIFAR-10 class for an image.

        Args:
            image_input: File path, PIL Image, or Werkzeug FileStorage.
            original_img_path (str, optional): Saved original image path for Grad-CAM.
            generate_gradcam_vis (bool): Whether to generate Grad-CAM heatmap.

        Returns:
            Dict containing:
                - predicted_class (str): Name of top predicted category.
                - confidence_score (float): Confidence percentage (0-100).
                - confidence_formatted (str): Formatted string (e.g. "98.54%").
                - probabilities (List[Dict]): List of all 10 class names and probabilities.
                - top_3 (List[Dict]): Top 3 highest predicted classes.
                - gradcam_url (str, optional): Relative static URL to Grad-CAM visualization image.
        """

        if self.model is None:
            # Fallback initialization if model was not pre-built
            from train_model import create_initial_model_weights

            create_initial_model_weights()
            self.model = tf.keras.models.load_model(self.model_path)

        # Preprocess input image to shape (1, 32, 32, 3)
        img_batch, resized_img = preprocess_image(image_input)

        # Execute prediction inference
        raw_probs = self.model.predict(img_batch, verbose=0)[0]

        # Convert probabilities to standard Python floats
        probs_float = [float(p) for p in raw_probs]

        # Top prediction index and confidence
        top_idx = int(np.argmax(probs_float))
        predicted_class = self.class_names[top_idx]
        top_confidence = probs_float[top_idx] * 100.0

        # Construct full class probability list
        all_probabilities = [
            {
                "class_name": self.class_names[i],
                "probability": float(probs_float[i]),
                "percentage": round(float(probs_float[i]) * 100.0, 2),
            }
            for i in range(len(self.class_names))
        ]

        # Sort top 3 predictions
        sorted_probs = sorted(
            all_probabilities, key=lambda x: x["probability"], reverse=True
        )
        top_3_predictions = sorted_probs[:3]

        # Generate Grad-CAM visualization if original image path provided
        gradcam_url = None
        if generate_gradcam_vis and original_img_path and os.path.exists(original_img_path):
            base_dir = os.path.dirname(original_img_path)
            file_name = os.path.basename(original_img_path)
            gradcam_filename = f"gradcam_{file_name}"
            gradcam_dest_path = os.path.join(base_dir, gradcam_filename)

            saved_path = generate_gradcam(
                model=self.model,
                img_array=img_batch,
                original_img_path=original_img_path,
                output_heatmap_path=gradcam_dest_path,
                pred_index=top_idx,
            )

            if saved_path:
                # Convert back to static URL relative path
                if "static/" in saved_path.replace("\\", "/"):
                    gradcam_url = saved_path.replace("\\", "/").split("static/")[1]
                    gradcam_url = f"/static/{gradcam_url}"

        return {
            "predicted_class": predicted_class,
            "confidence_score": round(top_confidence, 2),
            "confidence_formatted": f"{top_confidence:.2f}%",
            "probabilities": sorted_probs,
            "all_classes_ordered": all_probabilities,
            "top_3": top_3_predictions,
            "gradcam_url": gradcam_url,
        }
