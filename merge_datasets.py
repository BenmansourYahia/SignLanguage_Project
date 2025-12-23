"""
Merge Kaggle ASL Dataset with Custom Images

This script combines:
- Kaggle's 87,000 images (downloaded via download_kaggle_dataset.py)
- Your custom 5,720 images (in trainingdata/)

Result: ~92,000 total images for superior training!
"""

import os
import shutil
from pathlib import Path
from PIL import Image

# Configuration
KAGGLE_DIR = "kaggle_dataset/asl_alphabet_train"  # Fixed path
CUSTOM_DIR = "trainingdata"
OUTPUT_DIR = "combined_dataset"
TARGET_SIZE = 224  # Resize all to same size

print("="*60)
print("Dataset Merger - Kaggle + Custom Images")
print("="*60)

# Check if Kaggle dataset exists
if not os.path.exists(KAGGLE_DIR):
    print(f"\n❌ Kaggle dataset not found!")
    print(f"Expected location: {KAGGLE_DIR}")
    print(f"\nPlease run: python download_kaggle_dataset.py")
    exit(1)

# Check if custom dataset exists
if not os.path.exists(CUSTOM_DIR):
    print(f"\n❌ Custom dataset not found!")
    print(f"Expected location: {CUSTOM_DIR}")
    exit(1)

print(f"\n✓ Found Kaggle dataset: {KAGGLE_DIR}")
print(f"✓ Found custom dataset: {CUSTOM_DIR}")

# Create output directory
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Get all classes
kaggle_classes = set(os.listdir(KAGGLE_DIR))
custom_classes = set(os.listdir(CUSTOM_DIR))

all_classes = kaggle_classes.union(custom_classes)
print(f"\n✓ Found {len(all_classes)} total classes")
print(f"  Kaggle: {len(kaggle_classes)} classes")
print(f"  Custom: {len(custom_classes)} classes")

# Merge datasets
print(f"\n[Merging datasets...]")
print(f"This may take 10-15 minutes for 92,000 images...\n")

total_copied = 0
class_counts = {}

for class_name in sorted(all_classes):
    print(f"Processing class: {class_name}")
    
    # Create output folder
    output_class_dir = os.path.join(OUTPUT_DIR, class_name)
    os.makedirs(output_class_dir, exist_ok=True)
    
    copied_count = 0
    
    # Copy from Kaggle dataset
    kaggle_class_dir = os.path.join(KAGGLE_DIR, class_name)
    if os.path.exists(kaggle_class_dir):
        kaggle_images = [f for f in os.listdir(kaggle_class_dir) 
                        if f.endswith(('.jpg', '.png', '.jpeg'))]
        
        for i, img_file in enumerate(kaggle_images):
            src = os.path.join(kaggle_class_dir, img_file)
            dst = os.path.join(output_class_dir, f"kaggle_{i:05d}.jpg")
            
            try:
                # Resize and save
                img = Image.open(src)
                img = img.resize((TARGET_SIZE, TARGET_SIZE))
                img = img.convert('RGB')
                img.save(dst, 'JPEG')
                copied_count += 1
            except Exception as e:
                print(f"  ⚠ Skipped {img_file}: {e}")
    
    # Copy from custom dataset
    custom_class_dir = os.path.join(CUSTOM_DIR, class_name)
    if os.path.exists(custom_class_dir):
        custom_images = [f for f in os.listdir(custom_class_dir) 
                        if f.endswith(('.jpg', '.png', '.jpeg'))]
        
        for i, img_file in enumerate(custom_images):
            src = os.path.join(custom_class_dir, img_file)
            dst = os.path.join(output_class_dir, f"custom_{i:05d}.jpg")
            
            try:
                # Resize and save
                img = Image.open(src)
                img = img.resize((TARGET_SIZE, TARGET_SIZE))
                img = img.convert('RGB')
                img.save(dst, 'JPEG')
                copied_count += 1
            except Exception as e:
                print(f"  ⚠ Skipped {img_file}: {e}")
    
    class_counts[class_name] = copied_count
    total_copied += copied_count
    print(f"  ✓ {class_name}: {copied_count} images")

print("\n" + "="*60)
print("MERGE COMPLETE!")
print("="*60)
print(f"\n✓ Total images merged: {total_copied:,}")
print(f"✓ Output location: {OUTPUT_DIR}/")
print(f"\nClass breakdown:")
for class_name in sorted(class_counts.keys()):
    print(f"  {class_name}: {class_counts[class_name]:,} images")

print(f"\nNext steps:")
print(f"1. Update train_improved_model.py to use '{OUTPUT_DIR}'")
print(f"2. Run: python train_improved_model.py")
print(f"3. Training will take ~1-2 hours with this dataset!")
print("="*60)
