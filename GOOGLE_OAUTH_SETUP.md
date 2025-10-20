# Google OAuth Setup Guide for MailMind

This guide will help you set up Google OAuth authentication for the MailMind Flutter app.

## Prerequisites

1. **Google Cloud Console Account**: You need access to Google Cloud Console
2. **Backend Server**: Your backend must be running and support the Google OAuth endpoints
3. **Android Development**: For testing on Android devices/emulators

## Step 1: Google Cloud Console Setup

### 1.1 Create a New Project
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Click "Select a project" → "New Project"
3. Name your project (e.g., "MailMind App")
4. Click "Create"

### 1.2 Enable Google Sign-In API
1. In your project, go to "APIs & Services" → "Library"
2. Search for "Google Sign-In API" or "Google+ API"
3. Click on it and press "Enable"

### 1.3 Configure OAuth Consent Screen
1. Go to "APIs & Services" → "OAuth consent screen"
2. Choose "External" (for testing) or "Internal" (for organization use)
3. Fill in the required information:
   - **App name**: MailMind
   - **User support email**: Your email
   - **Developer contact information**: Your email
4. Add scopes: `email`, `profile`, `openid`
5. Save and continue

### 1.4 Create OAuth 2.0 Credentials
1. Go to "APIs & Services" → "Credentials"
2. Click "Create Credentials" → "OAuth 2.0 Client IDs"
3. Create credentials for different platforms:

#### For Android:
- **Application type**: Android
- **Name**: MailMind Android
- **Package name**: `com.example.mailmind` (or your package name)
- **SHA-1 certificate fingerprint**: Get this by running:
  ```bash
  # For debug keystore (development)
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  
  # For Windows
  keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```

#### For Web (if needed):
- **Application type**: Web application
- **Name**: MailMind Web
- **Authorized redirect URIs**: `http://localhost:3000/auth/google/callback`

## Step 2: Flutter App Configuration

### 2.1 Update Android Configuration

1. **Download google-services.json**:
   - In Google Cloud Console, go to your project settings
   - Download the `google-services.json` file
   - Place it in `android/app/google-services.json`

2. **Update android/build.gradle**:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.3.15'
   }
   ```

3. **Update android/app/build.gradle**:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   
   dependencies {
       implementation 'com.google.android.gms:play-services-auth:20.7.0'
   }
   ```

### 2.2 Update strings.xml
Update `android/app/src/main/res/values/strings.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">MailMind</string>
    <string name="default_web_client_id">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
</resources>
```

Replace `YOUR_WEB_CLIENT_ID` with the Web client ID from Google Cloud Console.

## Step 3: Backend Implementation

Your backend needs to implement the Google OAuth token verification endpoint:

### 3.1 Install Required Packages
```bash
npm install google-auth-library
```

### 3.2 Implement Token Verification Endpoint
```javascript
// Example Node.js/Express implementation
const { OAuth2Client } = require('google-auth-library');
const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

app.post('/auth/google/token', async (req, res) => {
  try {
    const { idToken, accessToken } = req.body;
    
    // Verify the ID token
    const ticket = await client.verifyIdToken({
      idToken: idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });
    
    const payload = ticket.getPayload();
    const { sub: googleId, email, name, picture } = payload;
    
    // Check if user exists or create new user
    let user = await User.findOne({ email });
    if (!user) {
      user = await User.create({
        email,
        name,
        googleId,
        avatar: picture,
      });
    }
    
    // Generate JWT token
    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET);
    
    res.json({
      access_token: token,
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
      }
    });
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});
```

## Step 4: Testing

### 4.1 Test the Implementation
1. Start your backend server on `http://localhost:3000`
2. Run the Flutter app: `flutter run`
3. Try signing in with Google
4. Check the console logs for any errors

### 4.2 Common Issues and Solutions

#### Issue: "Sign in failed"
- **Solution**: Check if Google Services are properly configured
- Verify SHA-1 fingerprint is correct
- Ensure `google-services.json` is in the right location

#### Issue: "Invalid client ID"
- **Solution**: Make sure the client ID in `strings.xml` matches the one from Google Cloud Console
- Check that the package name matches

#### Issue: "Backend connection failed"
- **Solution**: Ensure your backend is running on `localhost:3000`
- Check that the `/auth/google/token` endpoint is implemented
- Verify CORS settings allow requests from your app

## Step 5: Production Setup

### 5.1 Release Keystore
For production builds, you'll need to:
1. Generate a release keystore
2. Get the SHA-1 fingerprint of the release keystore
3. Add it to your Google Cloud Console OAuth client

### 5.2 Environment Variables
Set up environment variables for production:
```bash
GOOGLE_CLIENT_ID=your_google_client_id
JWT_SECRET=your_jwt_secret
```

## Troubleshooting

### Debug Mode
Enable debug logging in your Flutter app:
```dart
GoogleSignIn googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // Add this for debugging
  signInOption: SignInOption.standard,
);
```

### Check Logs
- **Android**: Use `flutter logs` or Android Studio logcat
- **Backend**: Check your server logs for token verification errors

## Security Notes

1. **Never expose client secrets** in your Flutter app
2. **Always verify tokens** on the backend
3. **Use HTTPS** in production
4. **Implement proper error handling** for failed authentications
5. **Store tokens securely** using Flutter Secure Storage

## Testing Checklist

- [ ] Google Cloud Console project created
- [ ] OAuth consent screen configured
- [ ] Android OAuth client created with correct SHA-1
- [ ] `google-services.json` downloaded and placed correctly
- [ ] Backend endpoint `/auth/google/token` implemented
- [ ] Flutter app can initiate Google Sign-In
- [ ] Backend can verify Google tokens
- [ ] User authentication flow works end-to-end
- [ ] Error handling works for failed sign-ins

## Support

If you encounter issues:
1. Check the [Google Sign-In Flutter documentation](https://pub.dev/packages/google_sign_in)
2. Review the [Google Identity documentation](https://developers.google.com/identity)
3. Check your backend logs for token verification errors
4. Ensure all configuration files are properly set up

---

**Note**: This setup is for development and testing. For production deployment, additional security measures and proper environment configuration are required.