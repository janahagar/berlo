#!/usr/bin/env python3
"""
Simple prediction script for Berlin landmarks model
"""

import pickle
import numpy as np
from PIL import Image

def load_model():
    """Load the trained model."""
    with open('berlin_landmarks_model.pkl', 'rb') as f:
        model = pickle.load(f)
    
    with open('landmark_labels.txt', 'r') as f:
        labels = [line.strip().split(': ')[1] for line in f]
    
    return model, labels

def predict_landmark(image_path, model, labels):
    """Predict landmark from image."""
    # Load and preprocess image
    img = Image.open(image_path)
    img = img.resize((224, 224))
    img_array = np.array(img)
    
    # Convert to grayscale and flatten
    if len(img_array.shape) == 3:
        img_gray = np.mean(img_array, axis=2)
    else:
        img_gray = img_array
    
    # Normalize and flatten
    img_normalized = img_gray / 255.0
    img_flattened = img_normalized.flatten().reshape(1, -1)
    
    # Predict
    prediction = model.predict(img_flattened)[0]
    confidence = model.predict_proba(img_flattened)[0].max()
    
    return labels[prediction], confidence

if __name__ == "__main__":
    model, labels = load_model()
    print(f"Model loaded with {len(labels)} classes")
    print(f"Classes: {labels}")
