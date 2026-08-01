"""
Production Flask Web Application for CIFAR-10 Image Classification.
Provides interactive web views, REST API endpoints, file validation,
structured logging, model explainability (Grad-CAM), and prediction reporting.
"""

import json
import logging
import os
import time
from datetime import datetime
from typing import Dict, Any

from flask import (
    Flask,
    render_template,
    request,
    jsonify,
    redirect,
    url_for,
    send_from_directory,
    make_response,
    Response,
)
from werkzeug.utils import secure_filename

from predict import CIFAR10Predictor
from utils.preprocess import validate_image_file, MAX_FILE_SIZE

# Initialize Flask application
app = Flask(__name__)

# Application Configurations
UPLOAD_FOLDER = os.path.join(app.root_path, "static", "uploads")
SAMPLES_FOLDER = os.path.join(app.root_path, "static", "samples")
LOGS_FOLDER = os.path.join(app.root_path, "logs")
MODEL_FOLDER = os.path.join(app.root_path, "model")

os.makedirs(UPLOAD_FOLDER, exist_ok=True)
os.makedirs(SAMPLES_FOLDER, exist_ok=True)
os.makedirs(LOGS_FOLDER, exist_ok=True)
os.makedirs(MODEL_FOLDER, exist_ok=True)

app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER
app.config["MAX_CONTENT_LENGTH"] = MAX_FILE_SIZE
app.config["SECRET_KEY"] = os.environ.get("SECRET_KEY", "cifar10_production_secret_key_2026")

# Configure Logging
log_file_path = os.path.join(LOGS_FOLDER, "app.log")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] in %(module)s: %(message)s",
    handlers=[
        logging.FileHandler(log_file_path, mode="a", encoding="utf-8"),
        logging.StreamHandler(),
    ],
)
logger = logging.getLogger("CIFAR10_App")
logger.info("CIFAR-10 Flask Application Initializing...")

# Initialize Predictor Singleton ONCE at startup
predictor = CIFAR10Predictor(
    model_path=os.path.join(MODEL_FOLDER, "cifar10_model.h5"),
    class_map_path=os.path.join(MODEL_FOLDER, "class_names.json"),
)


def wants_json_response() -> bool:
    """
    Check if the incoming request expects a JSON API response.
    """
    if request.args.get("format") == "json":
        return True
    accept_header = request.headers.get("Accept", "")
    return "application/json" in accept_header or request.is_json


# ============================================================================
# Web Routes & API Endpoints
# ============================================================================


@app.route("/", methods=["GET"])
def index():
    """
    Render Homepage with image uploader, drag & drop zone, and sample gallery.
    """
    # Collect available sample images for quick testing
    sample_files = []
    if os.path.exists(SAMPLES_FOLDER):
        sample_files = [
            f for f in os.listdir(SAMPLES_FOLDER)
            if f.lower().endswith((".png", ".jpg", ".jpeg"))
        ]

    return render_template("index.html", sample_images=sample_files)


@app.route("/predict", methods=["POST"])
def predict_endpoint():
    """
    Image Classification Endpoint.
    Accepts web form file uploads or API multipart/json requests.
    """
    start_time = time.time()

    # Handle file retrieval
    if "file" not in request.files:
        error_msg = "No image file provided in request."
        logger.warning(f"Prediction failed: {error_msg}")
        if wants_json_response():
            return jsonify({"error": error_msg, "success": False}), 400
        return render_template("index.html", error=error_msg), 400

    file = request.files["file"]

    # Validate file format and size
    is_valid, validation_error = validate_image_file(file)
    if not is_valid:
        logger.warning(f"File validation failed for '{file.filename}': {validation_error}")
        if wants_json_response():
            return jsonify({"error": validation_error, "success": False}), 400
        return render_template("index.html", error=validation_error), 400

    try:
        # Secure filename and add timestamp prefix to avoid collisions
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
        raw_filename = secure_filename(file.filename)
        filename = f"{timestamp}_{raw_filename}"
        saved_filepath = os.path.join(app.config["UPLOAD_FOLDER"], filename)

        # Save uploaded file
        file.save(saved_filepath)

        # Run Prediction Inference & Grad-CAM visualization
        prediction_result = predictor.predict(
            image_input=saved_filepath,
            original_img_path=saved_filepath,
            generate_gradcam_vis=True,
        )

        elapsed_ms = round((time.time() - start_time) * 1000, 2)

        # Log prediction result
        logger.info(
            f"SUCCESS | File: '{filename}' | Class: '{prediction_result['predicted_class']}' | "
            f"Confidence: {prediction_result['confidence_formatted']} | Latency: {elapsed_ms}ms"
        )

        # Return JSON API response if requested
        if wants_json_response():
            return jsonify(
                {
                    "success": True,
                    "filename": filename,
                    "prediction": prediction_result["predicted_class"],
                    "confidence": prediction_result["confidence_score"],
                    "confidence_formatted": prediction_result["confidence_formatted"],
                    "top_3": prediction_result["top_3"],
                    "probabilities": prediction_result["probabilities"],
                    "latency_ms": elapsed_ms,
                    "image_url": f"/static/uploads/{filename}",
                    "gradcam_url": prediction_result.get("gradcam_url"),
                }
            )

        # Render HTML results view
        return render_template(
            "result.html",
            filename=filename,
            image_url=url_for("static", filename=f"uploads/{filename}"),
            result=prediction_result,
            latency=elapsed_ms,
        )

    except Exception as e:
        logger.error(f"Error processing prediction for '{file.filename}': {str(e)}", exc_info=True)
        error_msg = f"An unexpected error occurred during prediction: {str(e)}"
        if wants_json_response():
            return jsonify({"error": error_msg, "success": False}), 500
        return render_template("index.html", error=error_msg), 500


@app.route("/sample-predict/<filename>", methods=["GET"])
def sample_predict(filename: str):
    """
    Run prediction directly on a pre-loaded sample image.
    """
    sample_path = os.path.join(SAMPLES_FOLDER, secure_filename(filename))
    if not os.path.exists(sample_path):
        return redirect(url_for("index"))

    try:
        prediction_result = predictor.predict(
            image_input=sample_path,
            original_img_path=sample_path,
            generate_gradcam_vis=True,
        )

        logger.info(
            f"SAMPLE PREDICT | File: '{filename}' | Class: '{prediction_result['predicted_class']}' | "
            f"Confidence: {prediction_result['confidence_formatted']}"
        )

        return render_template(
            "result.html",
            filename=filename,
            image_url=url_for("static", filename=f"samples/{filename}"),
            result=prediction_result,
            latency=0.0,
            is_sample=True,
        )
    except Exception as e:
        logger.error(f"Sample prediction error for '{filename}': {e}", exc_info=True)
        return redirect(url_for("index"))


@app.route("/model-info", methods=["GET"])
def model_info():
    """
    Display Model Information, Training Loss/Accuracy curves, and Confusion Matrix.
    """
    history_file = os.path.join(MODEL_FOLDER, "training_history.json")
    eval_file = os.path.join(MODEL_FOLDER, "evaluation_metrics.json")

    history_data = {}
    eval_data = {}

    if os.path.exists(history_file):
        with open(history_file, "r") as f:
            history_data = json.load(f)

    if os.path.exists(eval_file):
        with open(eval_file, "r") as f:
            eval_data = json.load(f)

    return render_template(
        "model_info.html",
        history=history_data,
        metrics=eval_data,
        class_names=predictor.class_names,
    )


@app.route("/download-report/<filename>", methods=["GET"])
def download_report(filename: str):
    """
    Generate and download text prediction report summary file.
    """
    clean_filename = secure_filename(filename)
    report_content = f"""====================================================
CIFAR-10 IMAGE CLASSIFICATION REPORT
Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}
Image File: {clean_filename}
====================================================

Top Prediction Result:
----------------------------------------------------
Predicted Class: {request.args.get('class', 'N/A')}
Confidence:      {request.args.get('confidence', 'N/A')}

CIFAR-10 Class List:
Airplane, Automobile, Bird, Cat, Deer, Dog, Frog, Horse, Ship, Truck

Application Engine:
Model Architecture: 3-Block Deep CNN (Conv2D + BatchNorm + ReLU + Dropout)
Framework: TensorFlow / Keras & Flask REST API
====================================================
"""
    response = make_response(report_content)
    response.headers["Content-Type"] = "text/plain"
    response.headers["Content-Disposition"] = f"attachment; filename=cifar10_report_{clean_filename}.txt"
    return response


@app.route("/api/health", methods=["GET"])
def health_check():
    """
    Health check API endpoint.
    """
    return jsonify(
        {
            "status": "healthy",
            "model_loaded": predictor.model is not None,
            "timestamp": datetime.now().isoformat(),
        }
    )


# ============================================================================
# Custom Error Handlers
# ============================================================================


@app.errorhandler(400)
def bad_request_error(e):
    if wants_json_response():
        return jsonify({"error": "Bad request", "details": str(e)}), 400
    return render_template("index.html", error="Bad request. Please try again."), 400


@app.errorhandler(404)
def not_found_error(e):
    if wants_json_response():
        return jsonify({"error": "Resource not found"}), 404
    return render_template("index.html", error="Page not found."), 404


@app.errorhandler(413)
def file_too_large_error(e):
    max_mb = app.config["MAX_CONTENT_LENGTH"] / (1024 * 1024)
    msg = f"Uploaded file is too large. Maximum allowed size is {max_mb:.0f} MB."
    logger.warning(f"HTTP 413: {msg}")
    if wants_json_response():
        return jsonify({"error": msg}), 413
    return render_template("index.html", error=msg), 413


@app.errorhandler(500)
def internal_server_error(e):
    logger.error(f"HTTP 500 Error: {e}", exc_info=True)
    if wants_json_response():
        return jsonify({"error": "Internal server error"}), 500
    return render_template("index.html", error="An internal server error occurred."), 500


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port, debug=True)
