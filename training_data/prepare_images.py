#!/usr/bin/env python3
"""
Image Preparation Script for Berlin Landmarks ML Training
This script helps resize and prepare images for training.
"""

import os
import sys
from PIL import Image
import glob

def resize_image(image_path, output_path, size=(224, 224)):
    """Resize image to specified size while maintaining aspect ratio."""
    try:
        with Image.open(image_path) as img:
            # Convert to RGB if necessary
            if img.mode != 'RGB':
                img = img.convert('RGB')
            
            # Resize with aspect ratio preservation
            img.thumbnail(size, Image.Resampling.LANCZOS)
            
            # Create new image with padding to reach target size
            new_img = Image.new('RGB', size, (255, 255, 255))
            new_img.paste(img, ((size[0] - img.width) // 2, (size[1] - img.height) // 2))
            
            # Save resized image
            new_img.save(output_path, 'JPEG', quality=85)
            return True
    except Exception as e:
        print(f"Error processing {image_path}: {e}")
        return False

def prepare_landmark_folder(landmark_folder):
    """Prepare all images in a landmark folder."""
    print(f"\n📸 Processing {landmark_folder}...")
    
    # Create processed folder
    processed_folder = f"{landmark_folder}_processed"
    if not os.path.exists(processed_folder):
        os.makedirs(processed_folder)
    
    # Get all image files
    image_extensions = ['*.jpg', '*.jpeg', '*.png', '*.bmp']
    image_files = []
    for ext in image_extensions:
        image_files.extend(glob.glob(os.path.join(landmark_folder, ext)))
        image_files.extend(glob.glob(os.path.join(landmark_folder, ext.upper())))
    
    if not image_files:
        print(f"❌ No images found in {landmark_folder}")
        return 0
    
    print(f"Found {len(image_files)} images")
    
    # Process each image
    processed_count = 0
    for image_path in image_files:
        filename = os.path.basename(image_path)
        output_path = os.path.join(processed_folder, f"{os.path.splitext(filename)[0]}.jpg")
        
        if resize_image(image_path, output_path):
            processed_count += 1
            print(f"✅ {filename}")
        else:
            print(f"❌ {filename}")
    
    print(f"Processed {processed_count}/{len(image_files)} images")
    return processed_count

def main():
    """Main function to prepare all landmark folders."""
    print("🏛️ Berlin Landmarks Image Preparation Tool")
    print("=" * 50)
    
    # Get all landmark folders
    landmark_folders = [
        'brandenburg_gate',
        'museum_island', 
        'berlin_cathedral',
        'east_side_gallery',
        'checkpoint_charlie',
        'gendarmenmarkt',
        'charlottenburg_palace',
        'tempelhofer_feld',
        'tiergarten_park',
        'potsdamer_platz',
        'victory_column',
        'berlin_zoo',
        'hackescher_markt',
        'prenzlauer_berg',
        'olympic_stadium'
    ]
    
    total_processed = 0
    
    for folder in landmark_folders:
        if os.path.exists(folder):
            processed = prepare_landmark_folder(folder)
            total_processed += processed
        else:
            print(f"⚠️  Folder {folder} not found")
    
    print("\n" + "=" * 50)
    print(f"🎉 Total images processed: {total_processed}")
    print("\n📋 Next steps:")
    print("1. Check the *_processed folders for resized images")
    print("2. Verify image quality and diversity")
    print("3. Follow the training guide to create your ML model")
    print("4. Upload the model to Firebase ML Kit")

if __name__ == "__main__":
    main() 