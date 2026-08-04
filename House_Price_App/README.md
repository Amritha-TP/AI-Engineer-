# House Price Prediction App

A complete, production-ready Flask web application for House Price Prediction (Regression) using a pre-trained Keras model.

## Project Overview

This responsive web application allows users to predict house prices using a pre-trained Deep Learning model (`house_price_model.h5`). 

The application automatically loads the Keras model upon startup, detects the expected number of input features, and dynamically generates a user-friendly, responsive HTML form. The interface is built with Bootstrap 5, featuring a modern design, dark/light mode, and PDF download functionality.

## Folder Structure

```
HousePricePrediction/
│── app.py
│── requirements.txt
│── README.md
│── house_price_model.h5 (Make sure to place your model here)
│
├── templates/
│      index.html
│      result.html
│      about.html
│
├── static/
│      style.css
│      script.js
│
└── utils/
       predictor.py
```

## Features

- **Dynamic Form Generation:** Automatically adapts to the number of input features expected by your Keras model.
- **Modern UI:** Built with Bootstrap 5, including a responsive navbar, gradient text, and hover animations.
- **Dark Mode Support:** Easily toggle between light and dark themes.
- **Prediction History:** Keeps track of recent predictions during your session.
- **PDF Export:** Download your prediction result as a PDF document.
- **Graceful Error Handling:** Provides meaningful error messages without crashing the application.

## Installation

Follow these steps to set up and run the application on your local machine.

### 1. Clone or Download the Project
Make sure you have all the project files in a single directory.

### 2. Create a Virtual Environment (Recommended)

**Windows:**
```bash
python -m venv venv
venv\Scripts\activate
```

**macOS/Linux:**
```bash
python3 -m venv venv
source venv/bin/activate
```

### 3. Install Dependencies
Install all required Python packages using `pip`:
```bash
pip install -r requirements.txt
```

### 4. Provide the Model
Ensure your trained Keras model is named `house_price_model.h5` and is placed in the root directory (alongside `app.py`).

### 5. Run the Application
Start the Flask development server:
```bash
python app.py
```

### 6. Open Browser
Navigate to the following URL to view the application:
```
http://127.0.0.1:5000
```
