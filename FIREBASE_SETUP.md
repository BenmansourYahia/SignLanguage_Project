# Firebase Setup Guide

## Step 1: Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **"Add project"**
3. Enter project name: **"ASL Detector"** (or any name)
4. Disable Google Analytics (optional, not needed)
5. Click **"Create project"**

## Step 2: Add Android App

1. In Firebase console, click **Android icon** (or "Add app")
2. Enter details:
   - **Android package name**: `com.example.signlanguage`
   - **App nickname**: ASL Detector
   - Leave SHA-1 blank for now
3. Click **"Register app"**

## Step 3: Download Configuration File

1. Download **`google-services.json`**
2. Place it in: `c:\Projetsign\signlanguage\android\app\`
   
   **Important:** Must be in `android/app/` folder, not root!

## Step 4: Enable Firestore Database

1. In Firebase console sidebar, click **"Firestore Database"**
2. Click **"Create database"**
3. Select **"Start in test mode"** (for now)
4. Choose location (select closest to you)
5. Click **"Enable"**

## Step 5: Configure Build Files

I'll update these files for you:
- `android/build.gradle`
- `android/app/build.gradle`

## What You Need to Do NOW

**ACTION REQUIRED:**
1. Create Firebase project (5 minutes)
2. Download `google-services.json`
3. Place file in `android/app/` folder
4. Let me know when done!

After you place the file, I'll:
- Update Android build files
- Add Firebase initialization
- Connect detection screen
- Test it works!

**Ready to start?** Go to console.firebase.google.com and follow Step 1-3 above!
