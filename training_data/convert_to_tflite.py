#!/usr/bin/env python3
"""
Convert TensorFlow model to TensorFlow Lite for mobile deployment
"""

import tensorflow as tf
import numpy as np
import os

def convert_to_tflite(model_path, output_path):
    """Convert TensorFlow model to TensorFlow Lite."""
    print(f"🔄 Converting {model_path} to TensorFlow Lite...")
    
    # Load the trained model
    model = tf.keras.models.load_model(model_path)
    
    # Create TensorFlow Lite converter
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    
    # Set optimization flags for mobile deployment
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    
    # Enable quantization for smaller model size
    converter.target_spec.supported_types = [tf.float16]
    
    # Convert the model
    tflite_model = converter.convert()
    
    # Save the TensorFlow Lite model
    with open(output_path, 'wb') as f:
        f.write(tflite_model)
    
    # Get model size
    model_size = os.path.getsize(output_path) / (1024 * 1024)  # MB
    
    print(f"✅ Model converted successfully!")
    print(f"📁 Saved as: {output_path}")
    print(f"📏 Model size: {model_size:.2f} MB")
    
    return model_size

def test_tflite_model(tflite_path, test_image_path=None):
    """Test the TensorFlow Lite model."""
    print(f"\n🧪 Testing TensorFlow Lite model...")
    
    # Load the TensorFlow Lite model
    interpreter = tf.lite.Interpreter(model_path=tflite_path)
    interpreter.allocate_tensors()
    
    # Get input and output details
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"📋 Model Details:")
    print(f"  Input shape: {input_details[0]['shape']}")
    print(f"  Input type: {input_details[0]['dtype']}")
    print(f"  Output shape: {output_details[0]['shape']}")
    print(f"  Output type: {output_details[0]['dtype']}")
    
    # Test with a dummy input
    input_shape = input_details[0]['shape']
    dummy_input = np.random.random(input_shape).astype(np.float32)
    
    interpreter.set_tensor(input_details[0]['index'], dummy_input)
    interpreter.invoke()
    
    output = interpreter.get_tensor(output_details[0]['index'])
    print(f"✅ Model test successful!")
    print(f"  Output shape: {output.shape}")
    print(f"  Output sum: {np.sum(output):.4f}")
    
    return True

def create_model_info_file(tflite_path, labels_path):
    """Create model information file for Firebase."""
    print(f"\n📝 Creating model info file...")
    
    # Read labels
    labels = []
    if os.path.exists(labels_path):
        with open(labels_path, 'r') as f:
            for line in f:
                labels.append(line.strip().split(': ')[1])
    
    # Create model info
    model_info = {
        "model_name": "berlin_landmarks_model",
        "version": "1.0",
        "description": "Custom Berlin landmarks recognition model",
        "input_shape": [1, 224, 224, 3],
        "output_shape": [1, len(labels)],
        "labels": labels,
        "model_size_mb": os.path.getsize(tflite_path) / (1024 * 1024),
        "framework": "TensorFlow Lite",
        "optimization": "Quantized (FP16)"
    }
    
    # Save as JSON
    import json
    with open('model_info.json', 'w') as f:
        json.dump(model_info, f, indent=2)
    
    print(f"✅ Model info saved as: model_info.json")
    
    return model_info

def main():
    """Main conversion function."""
    print("🔄 TensorFlow to TensorFlow Lite Converter")
    print("=" * 50)
    
    # Check if trained model exists
    model_path = "berlin_landmarks_model.h5"
    if not os.path.exists(model_path):
        print(f"❌ Error: {model_path} not found!")
        print("Please run train_model.py first to train the model.")
        return
    
    # Convert to TensorFlow Lite
    tflite_path = "berlin_landmarks_model.tflite"
    model_size = convert_to_tflite(model_path, tflite_path)
    
    # Test the converted model
    test_tflite_model(tflite_path)
    
    # Create model info
    labels_path = "landmark_labels.txt"
    model_info = create_model_info_file(tflite_path, labels_path)
    
    print(f"\n🎉 Conversion completed successfully!")
    print(f"\n📁 Files created:")
    print(f"  - {tflite_path} (TensorFlow Lite model)")
    print(f"  - model_info.json (model information)")
    print(f"\n📊 Model Statistics:")
    print(f"  - Size: {model_size:.2f} MB")
    print(f"  - Classes: {len(model_info['labels'])}")
    print(f"  - Input: {model_info['input_shape']}")
    print(f"  - Output: {model_info['output_shape']}")
    print(f"\n🚀 Next steps:")
    print(f"  1. Upload {tflite_path} to Firebase ML Kit")
    print(f"  2. Test in your Flutter app")
    print(f"  3. Deploy to production")

if __name__ == "__main__":
    main() 