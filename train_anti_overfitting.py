"""
Anti-Overfitting ASL Model Training

Improvements to prevent overfitting:
1. Early stopping with patience
2. Stronger regularization (L2 + higher dropout)
3. Better data augmentation
4. Larger image size (64x64 or 128x128)
5. More aggressive learning rate decay
"""

import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, regularizers
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import numpy as np
import os

# Configuration - ANTI-OVERFITTING SETTINGS
TRAINING_DATA_DIR = "combined_dataset"
IMAGE_SIZE = 64  # Increased from 32 to 64 for better detail
BATCH_SIZE = 32
EPOCHS = 50  # Max epochs, but early stopping will prevent overfitting
LEARNING_RATE = 0.001

print("="*60)
print("ASL Model Training - ANTI-OVERFITTING VERSION")
print("="*60)

# Check if training data exists
if not os.path.exists(TRAINING_DATA_DIR):
    print(f"\n❌ ERROR: '{TRAINING_DATA_DIR}' folder not found!")
    exit(1)

print(f"\n[1/5] Loading training data with STRONG augmentation...")

# STRONGER data augmentation to prevent overfitting
train_datagen = ImageDataGenerator(
    rescale=1./255,
    rotation_range=20,  # Increased from 15
    width_shift_range=0.15,  # Increased from 0.1
    height_shift_range=0.15,
    shear_range=0.1,  # NEW: Add shearing
    zoom_range=0.15,  # Increased from 0.1
    brightness_range=[0.8, 1.2],  # NEW: Brightness variation
    horizontal_flip=False,
    fill_mode='nearest',
    validation_split=0.2
)

# Validation data - NO augmentation (only rescaling)
val_datagen = ImageDataGenerator(
    rescale=1./255,
    validation_split=0.2
)

# Load training data
train_generator = train_datagen.flow_from_directory(
    TRAINING_DATA_DIR,
    target_size=(IMAGE_SIZE, IMAGE_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='sparse',
    subset='training',
    shuffle=True
)

# Load validation data
val_generator = val_datagen.flow_from_directory(
    TRAINING_DATA_DIR,
    target_size=(IMAGE_SIZE, IMAGE_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='sparse',
    subset='validation',
    shuffle=False
)

num_classes = len(train_generator.class_indices)
print(f"✓ Found {train_generator.samples} training images")
print(f"✓ Found {val_generator.samples} validation images")
print(f"✓ Number of classes: {num_classes}")

print(f"\n[2/5] Building REGULARIZED model architecture...")

# Model with STRONG regularization
model = keras.Sequential([
    # Input layer
    keras.layers.Input(shape=(IMAGE_SIZE, IMAGE_SIZE, 3)),
    
    # Block 1 - with L2 regularization
    keras.layers.Conv2D(32, (3, 3), activation='relu', padding='same',
                       kernel_regularizer=regularizers.l2(0.001)),
    keras.layers.BatchNormalization(),
    keras.layers.Conv2D(32, (3, 3), activation='relu', padding='same',
                       kernel_regularizer=regularizers.l2(0.001)),
    keras.layers.MaxPooling2D((2, 2)),
    keras.layers.Dropout(0.3),  # Increased from 0.25
    
    # Block 2
    keras.layers.Conv2D(64, (3, 3), activation='relu', padding='same',
                       kernel_regularizer=regularizers.l2(0.001)),
    keras.layers.BatchNormalization(),
    keras.layers.Conv2D(64, (3, 3), activation='relu', padding='same',
                       kernel_regularizer=regularizers.l2(0.001)),
    keras.layers.MaxPooling2D((2, 2)),
    keras.layers.Dropout(0.4),  # Increased from 0.25
    
    # Block 3 - NEW deeper layer
    keras.layers.Conv2D(128, (3, 3), activation='relu', padding='same',
                       kernel_regularizer=regularizers.l2(0.001)),
    keras.layers.BatchNormalization(),
    keras.layers.MaxPooling2D((2, 2)),
    keras.layers.Dropout(0.5),
    
    # Dense layers with strong regularization
    keras.layers.Flatten(),
    keras.layers.Dense(256, activation='relu',
                      kernel_regularizer=regularizers.l2(0.001)),
    keras.layers.BatchNormalization(),
    keras.layers.Dropout(0.6),  # Increased from 0.5
    
    keras.layers.Dense(128, activation='relu',
                      kernel_regularizer=regularizers.l2(0.001)),
    keras.layers.Dropout(0.5),
    
    keras.layers.Dense(num_classes, activation='softmax')
])

print("✓ Regularized model architecture created")
model.summary()

print(f"\n[3/5] Compiling model with optimizations...")

# Compile with Adam optimizer
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=LEARNING_RATE),
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# CRITICAL: Callbacks to prevent overfitting
callbacks = [
    # Save BEST model (not last)
    keras.callbacks.ModelCheckpoint(
        filepath='best_model.h5',
        monitor='val_accuracy',
        save_best_only=True,
        mode='max',
        verbose=1
    ),
    
    # EARLY STOPPING - stops when validation stops improving
    keras.callbacks.EarlyStopping(
        monitor='val_accuracy',
        patience=5,  # Stop if no improvement for 5 epochs
        restore_best_weights=True,
        verbose=1
    ),
    
    # Reduce learning rate when plateau
    keras.callbacks.ReduceLROnPlateau(
        monitor='val_loss',
        factor=0.5,
        patience=3,
        verbose=1,
        min_lr=0.00001
    ),
]

print("✓ Model compiled with EARLY STOPPING enabled")

print(f"\n[4/5] Training model (max {EPOCHS} epochs, early stopping enabled)...")
print("This will take a while. Progress will be shown below.\n")

# Train the model
history = model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=EPOCHS,
    callbacks=callbacks,
    verbose=1
)

print(f"\n[5/5] Training complete!")

# Print final results
final_train_acc = history.history['accuracy'][-1]
final_val_acc = history.history['val_accuracy'][-1]
gap = final_train_acc - final_val_acc

print(f"\n{'='*60}")
print(f"FINAL RESULTS:")
print(f"{'='*60}")
print(f"Training Accuracy:   {final_train_acc*100:.2f}%")
print(f"Validation Accuracy: {final_val_acc*100:.2f}%")
print(f"Overfitting Gap:     {gap*100:.2f}%")

if gap < 0.05:  # Less than 5% gap
    print(f"✓ EXCELLENT: Low overfitting!")
elif gap < 0.10:  # 5-10% gap
    print(f"⚠ ACCEPTABLE: Moderate overfitting")
else:  # >10% gap
    print(f"❌ WARNING: High overfitting detected!")

print(f"\n✓ Best model saved as 'best_model.h5'")
print(f"✓ Ready for conversion to TFLite!")
