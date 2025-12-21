"""
Fine-tune ASL Model with Your Own Images

This script helps you improve the model accuracy by training it on YOUR images!

Usage:
1. Organize your images in folders by sign name (see README below)
2. Run: python finetune_model.py
3. Replace assets/model.tflite with the generated fine_tuned_model.tflite
"""

import tensorflow as tf
from tensorflow import keras
import numpy as np
import os
from pathlib import Path
import cv2

# Configuration
TRAINING_DATA_DIR = "trainingdata"  # Your images folder
IMAGE_SIZE = 32  # Match the current model input size
BATCH_SIZE = 16
EPOCHS = 10
LEARNING_RATE = 0.0001

# All 29 ASL classes (must match labels.txt order!)
ALL_CLASSES = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 
               'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 
               'del', 'nothing', 'space']

print("="*60)
print("ASL Model Fine-Tuning Tool")
print("="*60)

# Check if training data exists
if not os.path.exists(TRAINING_DATA_DIR):
    print(f"\n❌ ERROR: '{TRAINING_DATA_DIR}' folder not found!")
    print("\nPlease create it and organize your images like this:")
    print(f"""
{TRAINING_DATA_DIR}/
├── A/
│   ├── img_001.jpg
│   ├── img_002.jpg
│   └── ... (10-30 images)
├── O/
│   └── ... (your images)
├── space/
│   └── ... (your images)
└── ... (other signs you want to improve)
    """)
    exit(1)

# Load and preprocess images
def load_images_from_folder(folder_path, label_index):
    """Load all images from a folder and assign the label"""
    images = []
    labels = []
    
    for img_file in Path(folder_path).glob("*.jpg") or Path(folder_path).glob("*.jpeg") or Path(folder_path).glob("*.png"):
        try:
            # Read image
            img = cv2.imread(str(img_file))
            if img is None:
                continue
            
            # Resize to model input size
            img = cv2.resize(img, (IMAGE_SIZE, IMAGE_SIZE))
            
            # Normalize to 0-1 (same as model expects)
            img = img.astype('float32') / 255.0
            
            images.append(img)
            labels.append(label_index)
        except Exception as e:
            print(f"⚠ Skipping {img_file}: {e}")
    
    return images, labels

# Load all training data
print(f"\n[1/5] Loading your training images from '{TRAINING_DATA_DIR}'...")
all_images = []
all_labels = []

available_folders = []
for class_name in ALL_CLASSES:
    class_folder = os.path.join(TRAINING_DATA_DIR, class_name)
    if os.path.exists(class_folder):
        available_folders.append(class_name)
        class_index = ALL_CLASSES.index(class_name)
        images, labels = load_images_from_folder(class_folder, class_index)
        all_images.extend(images)
        all_labels.extend(labels)
        print(f"  ✓ Loaded {len(images)} images for class '{class_name}'")

if len(all_images) == 0:
    print("\n❌ ERROR: No images found!")
    print("Make sure your images are in .jpg, .jpeg, or .png format")
    exit(1)

print(f"\n✓ Total: {len(all_images)} images from {len(available_folders)} classes")

# Convert to numpy arrays
X_train = np.array(all_images)
y_train = np.array(all_labels)

print(f"\n[2/5] Building model architecture...")
# Determine number of classes from the data
num_classes = len(set(all_labels))
print(f"  Detected {num_classes} classes in training data")

# Create a simple CNN model (similar to what's currently deployed)
model = keras.Sequential([
    keras.layers.Input(shape=(IMAGE_SIZE, IMAGE_SIZE, 3)),
    
    # Convolutional layers
    keras.layers.Conv2D(32, (3, 3), activation='relu'),
    keras.layers.MaxPooling2D((2, 2)),
    keras.layers.BatchNormalization(),
    
    keras.layers.Conv2D(64, (3, 3), activation='relu'),
    keras.layers.MaxPooling2D((2, 2)),
    keras.layers.BatchNormalization(),
    
    keras.layers.Conv2D(64, (3, 3), activation='relu'),
    
    # Dense layers
    keras.layers.Flatten(),
    keras.layers.Dense(128, activation='relu'),
    keras.layers.Dropout(0.5),
    keras.layers.Dense(num_classes, activation='softmax')  # Dynamic number of classes!
])

print("✓ Model architecture created")

# Compile model
print(f"\n[3/5] Compiling model...")
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=LEARNING_RATE),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)
print("✓ Model compiled")

# Train model
print(f"\n[4/5] Training model for {EPOCHS} epochs...")
print("This may take a few minutes depending on your data size...\n")

history = model.fit(
    X_train, y_train,
    batch_size=BATCH_SIZE,
    epochs=EPOCHS,
    validation_split=0.2,
    verbose=1
)

final_accuracy = history.history['accuracy'][-1] * 100
final_val_accuracy = history.history['val_accuracy'][-1] * 100
print(f"\n✓ Training complete!")
print(f"  Final training accuracy: {final_accuracy:.2f}%")
print(f"  Final validation accuracy: {final_val_accuracy:.2f}%")

# Convert to TFLite
print(f"\n[5/5] Converting to TFLite format...")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# Save the model
output_file = "fine_tuned_model.tflite"
with open(output_file, 'wb') as f:
    f.write(tflite_model)

print(f"✓ TFLite model saved as '{output_file}'")
print(f"  Size: {len(tflite_model) / 1024:.2f} KB")

# Verify the model
print(f"\n[Verification] Testing TFLite model...")
interpreter = tf.lite.Interpreter(model_path=output_file)
interpreter.allocate_tensors()

input_details = interpreter.get_input_details()
output_details = interpreter.get_output_details()

print(f"  Input shape: {input_details[0]['shape']}")
print(f"  Output shape: {output_details[0]['shape']}")
print(f"  Output classes: {output_details[0]['shape'][-1]}")

print("\n" + "="*60)
print("SUCCESS! Your custom model is ready!")
print("="*60)
print("\nNext steps:")
print(f"1. Copy '{output_file}' to your Flutter project")
print("2. Replace 'assets/model.tflite' with this new file")
print("3. Run: flutter run")
print("\nYour app will now recognize YOUR hand gestures better!")
print("="*60)
