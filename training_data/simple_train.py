#!/usr/bin/env python3
"""
Simple Berlin Landmarks Training Script
Uses a simpler approach for training a custom model.
"""

import os
import sys
import numpy as np
from PIL import Image
import glob
import json
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, classification_report
import pickle

# Configuration
IMG_SIZE = 224
BATCH_SIZE = 32

def load_and_preprocess_data(data_dir):
    """Load and preprocess images from processed folders."""
    print("📸 Loading training data...")
    
    images = []
    labels = []
    label_names = []
    
    # Get all processed folders
    processed_folders = glob.glob(os.path.join(data_dir, "*_processed"))
    processed_folders.sort()
    
    print(f"Found {len(processed_folders)} landmark folders:")
    
    for i, folder in enumerate(processed_folders):
        landmark_name = os.path.basename(folder).replace("_processed", "")
        label_names.append(landmark_name)
        
        print(f"  {i+1}. {landmark_name}")
        
        # Get all images in the folder
        image_files = glob.glob(os.path.join(folder, "*.jpg"))
        
        for image_file in image_files:
            try:
                # Load and preprocess image
                img = Image.open(image_file)
                img = img.resize((IMG_SIZE, IMG_SIZE))
                img_array = np.array(img)
                
                # Convert to grayscale and flatten
                if len(img_array.shape) == 3:
                    img_gray = np.mean(img_array, axis=2)
                else:
                    img_gray = img_array
                
                # Normalize and flatten
                img_normalized = img_gray / 255.0
                img_flattened = img_normalized.flatten()
                
                images.append(img_flattened)
                labels.append(i)
                
            except Exception as e:
                print(f"Error loading {image_file}: {e}")
    
    # Convert to numpy arrays
    X = np.array(images)
    y = np.array(labels)
    
    print(f"\n📊 Dataset Summary:")
    print(f"  Total images: {len(X)}")
    print(f"  Feature dimension: {X.shape[1]}")
    print(f"  Number of classes: {len(label_names)}")
    
    # Print class distribution
    unique, counts = np.unique(y, return_counts=True)
    print(f"\n📈 Class Distribution:")
    for i, (label, count) in enumerate(zip(unique, counts)):
        print(f"  {label_names[label]}: {count} images")
    
    return X, y, label_names

def train_simple_model(X_train, y_train, X_val, y_val, label_names):
    """Train a simple Random Forest model."""
    print(f"\n🌲 Training Random Forest model...")
    
    # Create and train Random Forest
    rf_model = RandomForestClassifier(
        n_estimators=100,
        max_depth=20,
        random_state=42,
        n_jobs=-1
    )
    
    print(f"Training samples: {len(X_train)}")
    print(f"Validation samples: {len(X_val)}")
    
    # Train the model
    rf_model.fit(X_train, y_train)
    
    # Evaluate on validation set
    y_pred = rf_model.predict(X_val)
    accuracy = accuracy_score(y_val, y_pred)
    
    print(f"Validation Accuracy: {accuracy:.4f} ({accuracy*100:.2f}%)")
    
    return rf_model

def evaluate_model(model, X_test, y_test, label_names):
    """Evaluate the trained model."""
    print(f"\n📊 Evaluating model...")
    
    # Predictions
    predictions = model.predict(X_test)
    
    # Calculate accuracy
    accuracy = accuracy_score(y_test, predictions)
    print(f"Test Accuracy: {accuracy:.4f} ({accuracy*100:.2f}%)")
    
    # Classification report
    print(f"\n📋 Classification Report:")
    print(classification_report(y_test, predictions, target_names=label_names))
    
    return accuracy

def save_model_and_labels(model, label_names, accuracy):
    """Save the model and label mapping."""
    print(f"\n💾 Saving model and labels...")
    
    # Save the model
    with open('berlin_landmarks_model.pkl', 'wb') as f:
        pickle.dump(model, f)
    print(f"Model saved as: berlin_landmarks_model.pkl")
    
    # Save label names
    with open('landmark_labels.txt', 'w') as f:
        for i, label in enumerate(label_names):
            f.write(f"{i}: {label}\n")
    print(f"Labels saved as: landmark_labels.txt")
    
    # Save model info
    model_info = {
        "model_name": "berlin_landmarks_model",
        "version": "1.0",
        "description": "Random Forest model for Berlin landmarks recognition",
        "input_shape": [IMG_SIZE * IMG_SIZE],
        "output_shape": [len(label_names)],
        "labels": label_names,
        "accuracy": accuracy,
        "framework": "Random Forest",
        "feature_type": "Flattened grayscale"
    }
    
    with open('model_info.json', 'w') as f:
        json.dump(model_info, f, indent=2)
    print(f"Model info saved as: model_info.json")

def create_simple_prediction_script():
    """Create a simple prediction script for testing."""
    script_content = '''#!/usr/bin/env python3
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
'''
    
    with open('predict_landmark.py', 'w') as f:
        f.write(script_content)
    print(f"Prediction script saved as: predict_landmark.py")

def main():
    """Main training function."""
    print("🏛️ Simple Berlin Landmarks Model Training")
    print("=" * 50)
    
    # Check if processed data exists
    if not os.path.exists("."):
        print("❌ Error: No processed data found!")
        print("Please run prepare_images.py first.")
        return
    
    # Load data
    X, y, label_names = load_and_preprocess_data(".")
    
    if len(X) == 0:
        print("❌ No images found! Please add images to the folders first.")
        return
    
    # Split data
    X_train, X_temp, y_train, y_temp = train_test_split(
        X, y, test_size=0.3, random_state=42, stratify=y
    )
    X_val, X_test, y_val, y_test = train_test_split(
        X_temp, y_temp, test_size=0.5, random_state=42, stratify=y_temp
    )
    
    print(f"\n📊 Data Split:")
    print(f"  Training: {len(X_train)} images")
    print(f"  Validation: {len(X_val)} images")
    print(f"  Test: {len(X_test)} images")
    
    # Train model
    model = train_simple_model(X_train, y_train, X_val, y_val, label_names)
    
    # Evaluate model
    accuracy = evaluate_model(model, X_test, y_test, label_names)
    
    # Save model and labels
    save_model_and_labels(model, label_names, accuracy)
    
    # Create prediction script
    create_simple_prediction_script()
    
    print(f"\n🎉 Training completed successfully!")
    print(f"Final Test Accuracy: {accuracy*100:.2f}%")
    print(f"\n📁 Files created:")
    print(f"  - berlin_landmarks_model.pkl (Random Forest model)")
    print(f"  - landmark_labels.txt (label mapping)")
    print(f"  - model_info.json (model information)")
    print(f"  - predict_landmark.py (prediction script)")
    print(f"\n🚀 Next steps:")
    print(f"  1. Test the model: python predict_landmark.py")
    print(f"  2. Integrate with your Flutter app")
    print(f"  3. Consider upgrading to TensorFlow for better performance")

if __name__ == "__main__":
    main() 