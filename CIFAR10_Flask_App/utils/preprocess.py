"""
Image Preprocessing and Validation Utilities for CIFAR-10 Flask Application.
"""

import os
from typing import Tuple, Union
import numpy as np
from PIL import Image

# Allowed image extensions
ALLOWED_EXTENSIONS = {"png", "jpg", "jpeg"}

# Maximum file upload size: 5 MB in bytes
MAX_FILE_SIZE = 5 * 1024 * 1024


def allowed_file(filename: str) -> bool:
    """
    Check if the file extension is allowed.

    Args:
        filename (str): Name of the uploaded file.

    Returns:
        bool: True if allowed extension, False otherwise.
    """
    if "." not in filename:
        return False
    ext = filename.rsplit(".", 1)[1].lower()
    return ext in ALLOWED_EXTENSIONS


def validate_image_file(
    file_storage, max_size: int = MAX_FILE_SIZE
) -> Tuple[bool, str]:
    """
    Validate uploaded image file format and file size.

    Args:
        file_storage: Werkzeug FileStorage instance.
        max_size (int): Max allowed size in bytes (default 5MB).

    Returns:
        Tuple[bool, str]: (is_valid, error_message)
    """
    if not file_storage or file_storage.filename == "":
        return False, "No file selected for upload."

    if not allowed_file(file_storage.filename):
        allowed_list = ", ".join(sorted(ALLOWED_EXTENSIONS)).upper()
        return (
            False,
            f"Invalid file format. Allowed image types: {allowed_list}.",
        )

    # Check file size by seeking stream
    file_storage.seek(0, os.SEEK_END)
    file_length = file_storage.tell()
    file_storage.seek(0)  # Reset pointer back to beginning

    if file_length > max_size:
        max_mb = max_size / (1024 * 1024)
        return (
            False,
            f"File size exceeds maximum limit of {max_mb:.1f} MB (Uploaded size: {file_length / (1024 * 1024):.2f} MB).",
        )

    return True, ""


def preprocess_image(
    image_input: Union[str, Image.Image], target_size: Tuple[int, int] = (32, 32)
) -> Tuple[np.ndarray, Image.Image]:
    """
    Preprocess image for CIFAR-10 model input.

    - Convert to RGB
    - Resize to target size (32x32)
    - Normalize array to range [0, 1]
    - Expand dimensions to (1, 32, 32, 3)

    Args:
        image_input (Union[str, Image.Image]): File path or PIL Image object.
        target_size (Tuple[int, int]): Target dimensions (width, height).

    Returns:
        Tuple[np.ndarray, Image.Image]:
            - Preprocessed numpy array ready for Keras prediction: shape (1, 32, 32, 3)
            - Resized 32x32 PIL Image object (RGB)
    """
    if isinstance(image_input, str):
        image = Image.open(image_input)
    elif isinstance(image_input, Image.Image):
        image = image_input
    else:
        raise ValueError("Invalid image input type. Expected file path or PIL Image.")

    # Ensure 3-channel RGB format (removes alpha or grayscale if any)
    if image.mode != "RGB":
        image = image.convert("RGB")

    # Resize image using high-quality Bilinear/Lanczos resampling
    image_resized = image.resize(target_size, Image.Resampling.BILINEAR)

    # Convert PIL Image to float32 numpy array
    img_array = np.asarray(image_resized, dtype=np.float32)

    # Normalize pixel values to range [0, 1]
    img_normalized = img_array / 255.0

    # Expand batch dimension -> (1, 32, 32, 3)
    img_batch = np.expand_dims(img_normalized, axis=0)

    return img_batch, image_resized
