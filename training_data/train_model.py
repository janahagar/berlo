#!/usr/bin/env python3
"""
Berlin Landmarks ML Model Training Script
Trains a custom TensorFlow model for Berlin landmark recognition.
"""

import os
import sys
import numpy as np
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint, ReduceLROnPlateau
from tensorflow.keras.optimizers import Adam
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
import glob
from PIL import Image

# Configuration
IMG_SIZE = 224
BATCH_SIZE = 32
EPOCHS = 50
LEARNING_RATE = 0.001
VALIDATION_SPLIT = 0.2

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
                img_array = np.array(img) / 255.0  # Normalize to [0,1]
                
                images.append(img_array)
                labels.append(i)
                
            except Exception as e:
                print(f"Error loading {image_file}: {e}")
    
    # Convert to numpy arrays
    X = np.array(images)
    y = np.array(labels)
    
    print(f"\n📊 Dataset Summary:")
    print(f"  Total images: {len(X)}")
    print(f"  Image shape: {X.shape[1:]}")
    print(f"  Number of classes: {len(label_names)}")
    
    # Print class distribution
    unique, counts = np.unique(y, return_counts=True)
    print(f"\n📈 Class Distribution:")
    for i, (label, count) in enumerate(zip(unique, counts)):
        print(f"  {label_names[label]}: {count} images")
    
    return X, y, label_names

def create_model(num_classes):
    """Create the neural network model."""
    print(f"\n🏗️ Creating model for {num_classes} classes...")
    
    # Use MobileNetV2 as base model (good for mobile deployment)
    base_model = MobileNetV2(
        weights='imagenet',
        include_top=False,
        input_shape=(IMG_SIZE, IMG_SIZE, 3)
    )
    
    # Freeze base model layers
    base_model.trainable = False
    
    # Add custom classification layers
    x = base_model.output
    x = GlobalAveragePooling2D()(x)
    x = Dense(1024, activation='relu')(x)
    x = Dropout(0.5)(x)
    x = Dense(512, activation='relu')(x)
    x = Dropout(0.3)(x)
    predictions = Dense(num_classes, activation='softmax')(x)
    
    model = Model(inputs=base_model.input, outputs=predictions)
    
    # Compile model
    model.compile(
        optimizer=Adam(learning_rate=LEARNING_RATE),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    
    print(f"Model created successfully!")
    print(f"Total parameters: {model.count_params():,}")
    
    return model

def train_model(model, X_train, y_train, X_val, y_val, label_names):
    """Train the model with callbacks."""
    print(f"\n🎯 Starting training...")
    print(f"Training samples: {len(X_train)}")
    print(f"Validation samples: {len(X_val)}")
    
    # Data augmentation for training
    datagen = ImageDataGenerator(
        rotation_range=20,
        width_shift_range=0.2,
        height_shift_range=0.2,
        horizontal_flip=True,
        zoom_range=0.2,
        brightness_range=[0.8, 1.2]
    )
    
    # Callbacks
    callbacks = [
        EarlyStopping(
            monitor='val_accuracy',
            patience=10,
            restore_best_weights=True,
            verbose=1
        ),
        ModelCheckpoint(
            'best_berlin_landmarks_model.h5',
            monitor='val_accuracy',
            save_best_only=True,
            verbose=1
        ),
        ReduceLROnPlateau(
            monitor='val_loss',
            factor=0.5,
            patience=5,
            min_lr=1e-7,
            verbose=1
        )
    ]
    
    # Train the model
    history = model.fit(
        datagen.flow(X_train, y_train, batch_size=BATCH_SIZE),
        validation_data=(X_val, y_val),
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1
    )
    
    return history

def evaluate_model(model, X_test, y_test, label_names):
    """Evaluate the trained model."""
    print(f"\n📊 Evaluating model...")
    
    # Predictions
    predictions = model.predict(X_test)
    predicted_classes = np.argmax(predictions, axis=1)
    
    # Calculate accuracy
    accuracy = np.mean(predicted_classes == y_test)
    print(f"Test Accuracy: {accuracy:.4f} ({accuracy*100:.2f}%)")
    
    # Confusion matrix
    from sklearn.metrics import confusion_matrix, classification_report
    cm = confusion_matrix(y_test, predicted_classes)
    
    print(f"\n📋 Classification Report:")
    print(classification_report(y_test, predicted_classes, target_names=label_names))
    
    return accuracy, cm

def save_model_and_labels(model, label_names):
    """Save the model and label mapping."""
    print(f"\n💾 Saving model and labels...")
    
    # Save the model
    model.save('berlin_landmarks_model.h5')
    print(f"Model saved as: berlin_landmarks_model.h5")
    
    # Save label names
    with open('landmark_labels.txt', 'w') as f:
        for i, label in enumerate(label_names):
            f.write(f"{i}: {label}\n")
    print(f"Labels saved as: landmark_labels.txt")
    
    # Save model summary
    with open('model_summary.txt', 'w') as f:
        model.summary(print_fn=lambda x: f.write(x + '\n'))
    print(f"Model summary saved as: model_summary.txt")

def plot_training_history(history):
    """Plot training history."""
    print(f"\n📈 Plotting training history...")
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))
    
    # Plot accuracy
    ax1.plot(history.history['accuracy'], label='Training Accuracy')
    ax1.plot(history.history['val_accuracy'], label='Validation Accuracy')
    ax1.set_title('Model Accuracy')
    ax1.set_xlabel('Epoch')
    ax1.set_ylabel('Accuracy')
    ax1.legend()
    ax1.grid(True)
    
    # Plot loss
    ax2.plot(history.history['loss'], label='Training Loss')
    ax2.plot(history.history['val_loss'], label='Validation Loss')
    ax2.set_title('Model Loss')
    ax2.set_xlabel('Epoch')
    ax2.set_ylabel('Loss')
    ax2.legend()
    ax2.grid(True)
    
    plt.tight_layout()
    plt.savefig('training_history.png', dpi=300, bbox_inches='tight')
    print(f"Training history saved as: training_history.png")

def main():
    """Main training function."""
    print("🏛️ Berlin Landmarks ML Model Training")
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
    
    # Create model
    model = create_model(len(label_names))
    
    # Train model
    history = train_model(model, X_train, y_train, X_val, y_val, label_names)
    
    # Evaluate model
    accuracy, cm = evaluate_model(model, X_test, y_test, label_names)
    
    # Save model and labels
    save_model_and_labels(model, label_names)
    
    # Plot training history
    plot_training_history(history)
    
    print(f"\n🎉 Training completed successfully!")
    print(f"Final Test Accuracy: {accuracy*100:.2f}%")
    print(f"\n📁 Files created:")
    print(f"  - berlin_landmarks_model.h5 (TensorFlow model)")
    print(f"  - landmark_labels.txt (label mapping)")
    print(f"  - model_summary.txt (model architecture)")
    print(f"  - training_history.png (training plots)")
    print(f"\n🚀 Next steps:")
    print(f"  1. Convert to TensorFlow Lite: python convert_to_tflite.py")
    print(f"  2. Upload to Firebase ML Kit")
    print(f"  3. Test in your Flutter app")

if __name__ == "__main__":
    main() 