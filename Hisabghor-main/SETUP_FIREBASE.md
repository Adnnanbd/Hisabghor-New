# Firebase Setup Guide for হিসাবঘর Pro

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `hisabghor-pro`
4. Enable Google Analytics (optional)
5. Click "Create project"

## Step 2: Add Android App to Firebase

1. In Firebase Console, click "Add app" → Select Android icon
2. Enter Android package name: `com.adnnan.hisabghor_pro`
3. Enter app nickname: `Hisabghor Pro`
4. Download `google-services.json`
5. Place the file in: `android/app/google-services.json`

## Step 3: Configure Android Build Files

### android/build.gradle
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### android/app/build.gradle
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'com.google.gms.google-services'  // Add this line
}

dependencies {
    // Firebase BoM
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    
    // Firebase dependencies
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.firebase:firebase-firestore'
    implementation 'com.google.firebase:firebase-storage'
    implementation 'com.google.firebase:firebase-database'
}
```

## Step 4: Enable Firebase Services

### Authentication
1. Go to Firebase Console → Authentication
2. Click "Get started"
3. Enable "Google" sign-in method
4. Add your SHA-1 certificate fingerprint:
   ```bash
   cd android
   ./gradlew signingReport
   ```
5. Copy SHA-1 and add it to Firebase Console

### Firestore Database
1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Start in **test mode** (we'll secure it later)
4. Choose location: `asia-southeast1` (closest to Bangladesh)

### Storage (Optional for product images)
1. Go to Firebase Console → Storage
2. Click "Get started"
3. Start in **test mode**

## Step 5: Configure Google Sign-In

### Generate SHA-1 Key
```bash
cd android
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### Add SHA-1 to Firebase
1. Go to Project Settings → Your apps
2. Add SHA-1 fingerprint
3. Download updated `google-services.json`

## Step 6: Set Up Firestore Security Rules

Go to Firestore Database → Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to access only their own data
    match /users/{userId}/{collection=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Admin can access all data
    match /{document=**} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
  }
}
```

## Step 7: Set Up Admin Email Notification (Optional)

### Option A: Using Firebase Cloud Functions

1. Install Firebase CLI:
   ```bash
   npm install -g firebase-tools
   ```

2. Initialize functions:
   ```bash
   firebase login
   firebase init functions
   ```

3. Create `functions/index.js`:
   ```javascript
   const functions = require('firebase-functions');
   const nodemailer = require('nodemailer');

   const transporter = nodemailer.createTransport({
     service: 'gmail',
     auth: {
       user: 'your-email@gmail.com',
       pass: 'your-app-password'
     }
   });

   exports.sendAdminNotification = functions.firestore
     .document('users/{userId}')
     .onCreate(async (snap, context) => {
       const userData = snap.data();
       
       const mailOptions = {
         from: 'Hisabghor Pro <noreply@hisabghor.com>',
         to: 'adnnanrahman@gmail.com',
         subject: 'New User Registration',
         html: `
           <h2>New User Registered</h2>
           <p><strong>Name:</strong> ${userData.name}</p>
           <p><strong>Email:</strong> ${userData.email}</p>
           <p><strong>Phone:</strong> ${userData.phone || 'N/A'}</p>
           <p><strong>Business:</strong> ${userData.businessName || 'N/A'}</p>
           <p><strong>Time:</strong> ${userData.registrationTime}</p>
         `
       };
       
       await transporter.sendMail(mailOptions);
     });
   ```

4. Deploy:
   ```bash
   firebase deploy --only functions
   ```

### Option B: Manual Email Notifications
For now, admin notifications are logged to console. You can check Firebase Console logs.

## Step 8: Test the Setup

### Run the App
```bash
flutter pub get
flutter run
```

### Test Google Sign-In
1. Open app
2. Click "Sign in with Google"
3. Select Google account
4. Check if you're redirected to home screen

### Verify Firebase Connection
1. Check Firebase Console → Authentication → Users
2. You should see the signed-in user

### Test Cloud Backup
1. Go to Settings → Backup & Restore
2. Click "Sync to Firebase"
3. Check Firestore Console for data

## Step 9: Production Security

Before releasing to Play Store:

### Update Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{collection=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null;
    }
  }
}
```

### Enable App Check (Recommended)
```bash
flutter pub add firebase_app_check
```

## Troubleshooting

### Common Issues

**1. Google Sign-In Fails**
- Ensure SHA-1 is added to Firebase
- Check package name matches exactly
- Verify OAuth consent screen is configured

**2. Firestore Permission Denied**
- Check security rules
- Ensure user is authenticated
- Verify user ID matches document path

**3. App Crashes on Startup**
- Ensure `google-services.json` is in correct location
- Check Firebase initialization in `main.dart`
- Verify all dependencies are installed

## Support

Developer: ADNNAN  
WhatsApp: +8801911-109390  
Email: adnnanrahman@gmail.com

---

**হিসাবঘর Pro - আপনার ব্যবসার ডিজিটাল পার্টনার**
