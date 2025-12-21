# Fine-Tuning ASL Model - Complete Guide

## Quick Start

### 1. Install Requirements
```bash
pip install tensorflow opencv-python numpy
```

### 2. Collect Your Images

Create a `training_data` folder with subfolders for each sign:

```
training_data/
├── A/
│   ├── img_001.jpg
│   ├── img_002.jpg
│   └── ... (10-30 images)
├── O/
│   └── ...
├── space/
│   └── ...
└── (only include signs you want to improve)
```

**How to take good photos:**
- Use your phone camera or webcam
- Same lighting you'll use the app in
- Same background as where you'll use it
- Hold the sign steady for each photo
- Take from different angles
- 10-30 photos per sign is enough

**You don't need all 29 signs!** Only photograph the ones that aren't working well.

### 3. Run the Training Script

```bash
python finetune_model.py
```

The script will:
- Load your images automatically
- Train the model (takes 2-10 minutes)
- Create `fine_tuned_model.tflite`
- Show you the accuracy

### 4. Update Your App

```bash
# Copy the new model
copy fine_tuned_model.tflite assets\model.tflite

# Run the app
flutter run
```

## Tips for Best Results

### Image Collection
- **Quantity**: 15-20 images per sign is ideal
- **Variety**: Different hand positions, angles
- **Consistency**: All from your phone/webcam
- **Lighting**: Match where you'll use the app

### If Accuracy is Low
- Add more images (try 30-50 per sign)
- Make sure images are clear and well-lit
- Include images with slight variations
- Run for more epochs (change `EPOCHS = 20` in script)

### Common Issues

**"No images found"**
- Check folder names match exactly (A, B, C, space, etc.)
- Images must be .jpg, .jpeg, or .png format
- Make sure `training_data/` folder is in the project directory

**"Model accuracy is low"**
- Add more varied images
- Check lighting in photos
- Make sure hand gestures are clear
- Train for more epochs

## Advanced Options

Edit `finetune_model.py` to customize:
- `IMAGE_SIZE = 32` - Model input size (keep at 32 for current model)
- `EPOCHS = 10` - Training iterations (increase for more accuracy)
- `LEARNING_RATE = 0.0001` - How fast model learns

## Example Workflow

1. **Test app** → Notice "O" and "space" get confused
2. **Take photos** → 20 images of "O", 20 of "space"
3. **Organize** → Put in `training_data/O/` and `training_data/space/`
4. **Train** → Run `python finetune_model.py`
5. **Deploy** → Copy model to `assets/`
6. **Test** → Much better accuracy!

That's it! Your app now recognizes YOUR hands specifically! 🎉
