"""
Download Kaggle ASL Alphabet Dataset

This script downloads the official ASL alphabet dataset from Kaggle.

Requirements:
1. Kaggle account (free at kaggle.com)
2. Kaggle API credentials (kaggle.json)

Setup Instructions:
1. Go to kaggle.com/settings
2. Scroll to "API" section
3. Click "Create New API Token"
4. Save kaggle.json to: C:\\Users\\<YourUsername>\\.kaggle\\kaggle.json
"""

import os
import sys

print("="*60)
print("Kaggle ASL Dataset Downloader")
print("="*60)

# Check if kaggle package is installed
try:
    import kaggle
    print("\n✓ Kaggle package found")
except ImportError:
    print("\n❌ Kaggle package not installed!")
    print("\nInstalling now...")
    os.system("pip install kaggle")
    print("\n✓ Kaggle package installed")
    import kaggle

# Check for API credentials
kaggle_dir = os.path.expanduser("~/.kaggle")
kaggle_json = os.path.join(kaggle_dir, "kaggle.json")

if not os.path.exists(kaggle_json):
    print(f"\n❌ Kaggle API credentials not found!")
    print(f"\nPlease setup your Kaggle API:")
    print(f"1. Go to: https://www.kaggle.com/settings")
    print(f"2. Scroll to 'API' section")
    print(f"3. Click 'Create New API Token'")
    print(f"4. Save kaggle.json to: {kaggle_json}")
    print(f"\nThen run this script again.")
    sys.exit(1)

print(f"✓ Kaggle API credentials found")

# Download dataset
DATASET = "grassknoted/asl-alphabet"
OUTPUT_DIR = "kaggle_dataset"

print(f"\n[1/2] Downloading dataset: {DATASET}")
print(f"This is ~1.1 GB and may take a few minutes...")
print()

try:
    # Create output directory
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    
    # Download and unzip
    kaggle.api.dataset_download_files(
        DATASET,
        path=OUTPUT_DIR,
        unzip=True
    )
    
    print(f"\n✓ Dataset downloaded successfully!")
    
except Exception as e:
    print(f"\n❌ Download failed: {e}")
    print(f"\nTroubleshooting:")
    print(f"1. Check your internet connection")
    print(f"2. Verify Kaggle API credentials")
    print(f"3. Make sure you've accepted dataset terms on Kaggle website")
    sys.exit(1)

# Check downloaded files
print(f"\n[2/2] Verifying download...")

asl_train = os.path.join(OUTPUT_DIR, "asl_alphabet_train", "asl_alphabet_train")
asl_test = os.path.join(OUTPUT_DIR, "asl_alphabet_test", "asl_alphabet_test")

if os.path.exists(asl_train):
    # Count folders (classes)
    classes = [d for d in os.listdir(asl_train) if os.path.isdir(os.path.join(asl_train, d))]
    print(f"✓ Found {len(classes)} classes in training set")
    
    # Count total images
    total_images = 0
    for class_name in classes:
        class_path = os.path.join(asl_train, class_name)
        image_count = len([f for f in os.listdir(class_path) if f.endswith(('.jpg', '.png'))])
        total_images += image_count
        print(f"  {class_name}: {image_count} images")
    
    print(f"\n✓ Total training images: {total_images}")
else:
    print(f"❌ Training data not found at expected location")
    print(f"Expected: {asl_train}")

print("\n" + "="*60)
print("DOWNLOAD COMPLETE!")
print("="*60)
print(f"\nDataset location: {OUTPUT_DIR}/")
print(f"\nNext steps:")
print(f"1. Run: python merge_datasets.py")
print(f"2. This will combine Kaggle + your custom images")
print("="*60)
