import os
import numpy as np
from tensorflow.keras.models import load_model

class HousePricePredictor:
    def __init__(self, model_path="house_price_model.h5"):
        self.model_path = model_path
        self.model = None
        self.input_shape = None
        self.num_features = None
        self.output_shape = None
        self.is_loaded = False
        
        self.load_keras_model()
        
    def load_keras_model(self):
        """Loads the Keras model and inspects its properties."""
        if not os.path.exists(self.model_path):
            print(f"Error: Model file '{self.model_path}' not found.")
            return

        try:
            self.model = load_model(self.model_path)
            self.is_loaded = True
            
            # Inspect model shape
            # model.input_shape typically looks like (None, num_features)
            self.input_shape = self.model.input_shape
            if len(self.input_shape) > 1:
                self.num_features = self.input_shape[1]
            else:
                self.num_features = 13 # fallback if shape is weird
                
            self.output_shape = self.model.output_shape
            
            print("="*40)
            print("MODEL LOADED SUCCESSFULLY")
            print(f"Input Shape: {self.input_shape}")
            print(f"Number of Input Features: {self.num_features}")
            print(f"Output Shape: {self.output_shape}")
            print("="*40)
            
        except Exception as e:
            print(f"Error loading model: {e}")
            self.is_loaded = False
            
    def get_feature_names(self):
        """Returns default feature names based on expected input size."""
        if self.num_features == 13:
            return ["CRIM", "ZN", "INDUS", "CHAS", "NOX", "RM", "AGE", "DIS", "RAD", "TAX", "PTRATIO", "B", "LSTAT"]
        else:
            return [f"Feature {i+1}" for i in range(self.num_features or 0)]
            
    def predict(self, input_values):
        """
        Takes a list of string/float input values, preprocesses them,
        and returns the predicted price.
        """
        if not self.is_loaded:
            raise ValueError("Model is not loaded.")
            
        if len(input_values) != self.num_features:
            raise ValueError(f"Expected {self.num_features} features, got {len(input_values)}.")
            
        try:
            # Convert to float and create numpy array
            features_array = np.array([float(x) for x in input_values])
            
            # Reshape to match model expected input (1, num_features)
            features_reshaped = features_array.reshape(1, -1)
            
            # Predict
            prediction = self.model.predict(features_reshaped)
            
            # Typically, prediction is a 2D array like [[price]]
            return float(prediction[0][0])
            
        except ValueError:
            raise ValueError("All input values must be numeric.")
        except Exception as e:
            raise Exception(f"Prediction error: {str(e)}")
