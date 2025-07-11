# Firebase Setup Instructions

## Important: Firebase Service Account Key

This project requires a Firebase service account key file for backend operations.

### Setup Steps:

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Select your project**: `v-store-e2e87`
3. **Navigate to**: Project Settings → Service Accounts
4. **Generate new private key** (JSON format)
5. **Download the file** and rename it to: `v-store-e2e87-firebase-adminsdk-fbsvc-[YOUR-KEY-ID].json`
6. **Place the file** in the `assets/` directory

### Security Notice:
- **NEVER commit Firebase credentials to git**
- The actual key file is ignored by `.gitignore`
- Each developer needs their own service account key

### File Structure:
```
assets/
├── v-store-e2e87-firebase-adminsdk-fbsvc-[YOUR-KEY-ID].json  ← Your private key
└── firebase-setup.md  ← This instruction file
```

### Environment Variables (Alternative):
You can also set up environment variables instead of using the JSON file:
- `FIREBASE_PROJECT_ID`
- `FIREBASE_PRIVATE_KEY`
- `FIREBASE_CLIENT_EMAIL`

---
⚠️ **Remember**: Keep your Firebase credentials secure and never share them publicly!
