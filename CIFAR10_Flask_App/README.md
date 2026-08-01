# CIFAR-10 Image Classification Flask Web Application

A production-grade, end-to-end Flask web application that classifies images into CIFAR-10 categories using a Deep Convolutional Neural Network (CNN) built with TensorFlow/Keras. Features a modern, responsive UI with Bootstrap 5, interactive Chart.js probability visualizations, Grad-CAM explainability heatmaps, REST API endpoints, dark mode, prediction reports, and multi-platform deployment readiness (Docker, Render, Heroku, Railway).

---

## Key Features

- **Deep CNN Architecture**: 3-block Convolutional Neural Network with Batch Normalization, ReLU activations, Max Pooling, and Dropout for regularization.
- **Interactive Web UI**: Built with Bootstrap 5, Google Fonts (Outfit & Plus Jakarta Sans), gradient backgrounds, glassmorphism cards, and responsive layouts.
- **Probability Visualizations**: Horizontal bar chart powered by Chart.js displaying prediction probabilities across all 10 CIFAR-10 classes.
- **Explainable AI (Grad-CAM)**: Visualizes model feature activation heatmaps to explain *why* a specific prediction was made.
- **REST API Endpoints**: Accepts image file uploads via standard HTTP POST and returns structured JSON predictions when requested.
- **Quick Sample Testing**: Pre-loaded gallery of sample images to test the model instantly without uploading custom images.
- **Model Analytics Dashboard**: Interactive page displaying CNN layer specifications, loss/accuracy curves, and confusion matrix tables.
- **Dark Mode Support**: Persistent dark/light theme switching using CSS variables and `localStorage`.
- **Prediction Reports**: Downloadable prediction summary reports in plain text.
- **Production Logging**: Structured logging into `logs/app.log` capturing timestamps, uploaded filenames, predictions, confidence scores, latencies, and exceptions.
- **Deployment Ready**: Fully configured with `Dockerfile`, `Procfile`, `.dockerignore`, and `runtime.txt`.

---

## Project Structure

```
CIFAR10_Flask_App/
│
├── app.py                      # Main Flask application & REST API routes
├── predict.py                  # Singleton model predictor & Grad-CAM pipeline
├── train_model.py              # CNN architecture, dataset training, and evaluation script
├── requirements.txt            # Python dependencies
├── README.md                   # Complete documentation
├── Dockerfile                  # Container definition
├── .dockerignore               # Docker ignore rules
├── Procfile                    # Web server entrypoint for Heroku / Render / Railway
├── runtime.txt                 # Python version specification
├── .gitignore                  # Git ignore rules
│
├── model/
│   ├── cifar10_model.h5        # Trained Keras CNN model binary
│   ├── class_names.json        # Class mapping JSON
│   ├── training_history.json   # Epoch accuracy and loss history JSON
│   └── evaluation_metrics.json # Confusion matrix and test evaluation metrics JSON
│
├── static/
│   ├── css/
│   │   └── style.css           # Custom styling, gradients, dark mode, glassmorphism
│   ├── js/
│   │   └── main.js             # Drag-and-drop, Chart.js rendering, theme toggle logic
│   ├── uploads/                # Temporary directory for uploaded user images
│   └── samples/                # Sample test images for instant evaluation
│
├── templates/
│   ├── index.html              # Homepage with file uploader & sample gallery
│   ├── result.html             # Prediction results, Grad-CAM toggle & Chart.js table
│   └── model_info.html         # Model architecture & training metrics dashboard
│
├── utils/
│   ├── __init__.py
│   ├── preprocess.py           # Image validation, resizing (32x32), normalization
│   └── gradcam.py              # Grad-CAM heatmap visualization algorithm
│
└── logs/
    └── app.log                 # Production log file
```

---

## Dataset

The application is trained on the **CIFAR-10 Dataset** containing 60,000 32×32 color images across 10 classes:

| Class ID | Class Name | Description |
| :--- | :--- | :--- |
| 0 | **Airplane** | Commercial & military aircraft |
| 1 | **Automobile** | Cars, sedans, sports cars |
| 2 | **Bird** | Wild & domestic birds |
| 3 | **Cat** | Felines |
| 4 | **Deer** | Wild deer & elks |
| 5 | **Dog** | Canines |
| 6 | **Frog** | Amphibians |
| 7 | **Horse** | Horses & ponies |
| 8 | **Ship** | Boats, cargo ships, vessels |
| 9 | **Truck** | Heavy transport vehicles & pickups |

---

## CNN Model Architecture

```
Input (32 x 32 x 3 RGB Image)
  │
  ├── Block 1: Conv2D(32, 3x3) ──> BatchNormalization ──> ReLU ──> MaxPooling(2x2) ──> Dropout(0.25)
  │
  ├── Block 2: Conv2D(64, 3x3) ──> BatchNormalization ──> ReLU ──> MaxPooling(2x2) ──> Dropout(0.25)
  │
  ├── Block 3: Conv2D(128, 3x3) ──> BatchNormalization ──> ReLU
  │
  ├── Flatten (8192 vector)
  │
  ├── Dense (128 units, ReLU) ──> Dropout(0.50)
  │
  └── Dense Output (10 units, Softmax)
```

- **Optimizer**: Adam (learning rate = 0.001)
- **Loss Function**: Categorical Crossentropy
- **Metrics**: Accuracy

---

## Installation & Local Setup

### Prerequisites
- Python 3.10 or higher
- `pip` package manager

### 1. Clone or Navigate to Project
```bash
cd CIFAR10_Flask_App
```

### 2. Create Virtual Environment
```bash
# On Linux / macOS
python3 -m venv venv
source venv/bin/activate

# On Windows
python -m venv venv
venv\Scripts\activate
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

---

## Model Training & Quick Initialization

### Option A: Quick Initialization (Instant Startup)
Generates model structure and metadata instantly without waiting for full epoch training:
```bash
python train_model.py --quick-init
```

### Option B: Full CNN Model Training
Downloads the CIFAR-10 dataset and trains the network for 20 epochs:
```bash
python train_model.py --epochs 20 --batch-size 64
```

This exports `cifar10_model.h5`, `class_names.json`, `training_history.json`, and `evaluation_metrics.json` into the `model/` directory.

---

## Running the Flask Application

### Start Development Server
```bash
python app.py
```
Open your browser and navigate to:
```
http://localhost:5000
```

### Start Production Server (Gunicorn)
```bash
gunicorn app:app --bind 0.0.0.0:5000 --workers 2 --threads 4
```

---

## REST API Reference

### 1. Health Check Endpoint
- **URL**: `/api/health`
- **Method**: `GET`
- **Response**:
```json
{
  "status": "healthy",
  "model_loaded": true,
  "timestamp": "2026-08-01T00:40:00.000000"
}
```

### 2. Predict Image Endpoint
- **URL**: `/predict`
- **Method**: `POST`
- **Headers**: `Accept: application/json`
- **Body**: `multipart/form-data` with `file` field containing image (`.jpg`, `.jpeg`, `.png`)

#### Curl Example:
```bash
curl -X POST -F "file=@test_cat.jpg" -H "Accept: application/json" http://localhost:5000/predict
```

#### JSON Response:
```json
{
  "success": true,
  "filename": "20260801_004022_test_cat.jpg",
  "prediction": "Cat",
  "confidence": 98.54,
  "confidence_formatted": "98.54%",
  "top_3": [
    { "class_name": "Cat", "percentage": 98.54, "probability": 0.9854 },
    { "class_name": "Dog", "percentage": 0.82, "probability": 0.0082 },
    { "class_name": "Bird", "percentage": 0.31, "probability": 0.0031 }
  ],
  "latency_ms": 42.5,
  "image_url": "/static/uploads/20260801_004022_test_cat.jpg",
  "gradcam_url": "/static/uploads/gradcam_20260801_004022_test_cat.jpg"
}
```

---

## Docker Deployment

### 1. Build Docker Image
```bash
docker build -t cifar10-flask-app .
```

### 2. Run Container
```bash
docker run -d -p 5000:5000 --name cifar10-app cifar10-flask-app
```
Access at `http://localhost:5000`.

---

## Cloud Deployment Guide

### Deploying to Render / Railway / Heroku
1. Push repository to GitHub.
2. Connect your GitHub repository to **Render**, **Railway**, or **Heroku**.
3. Select **Python Environment** or **Docker Container**.
4. The deployment will automatically use `Procfile` and `requirements.txt`.

---

## License & Credits

Built with Python, Flask, TensorFlow, Keras, Bootstrap 5, Chart.js, and PIL.
Designed and implemented following production software engineering best practices.
