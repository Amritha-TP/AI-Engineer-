from flask import Flask, render_template, request, jsonify, session, redirect, url_for
from utils.predictor import HousePricePredictor
import os
import secrets

app = Flask(__name__)
# Generate a random secret key for session management
app.secret_key = secrets.token_hex(16)

# Initialize predictor globally
predictor = HousePricePredictor()

@app.route('/')
def index():
    if not predictor.is_loaded:
        return render_template('index.html', 
                               error="Model is missing or invalid. Please place 'house_price_model.h5' in the project root.",
                               features=[])
                               
    features = predictor.get_feature_names()
    history = session.get('history', [])
    return render_template('index.html', features=features, history=history)

@app.route('/predict', methods=['POST'])
def predict():
    if not predictor.is_loaded:
        return render_template('result.html', error="Model is not loaded.")
        
    try:
        features = predictor.get_feature_names()
        input_values = []
        for feature in features:
            # Form fields will be named feature_0, feature_1, etc.
            val = request.form.get(feature)
            if val is None or val.strip() == "":
                raise ValueError(f"Missing value for {feature}")
            input_values.append(val)
            
        prediction = round(predictor.predict(input_values),2)
        # Save to session history
        history = session.get('history', [])
        # Prepend to keep latest first
        history.insert(0, {'price': prediction, 'inputs': input_values})
        # Keep only last 5
        session['history'] = history[:5]
        
        return render_template('result.html', prediction=prediction)
        
    except ValueError as ve:
        return render_template('result.html', error=str(ve))
    except Exception as e:
        return render_template('result.html', error="An error occurred during prediction.")

@app.route('/about')
def about():
    return render_template('about.html')

@app.route('/reset')
def reset():
    session.pop('history', None)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)
