# ShuttleSync Setup Instructions

## Google Maps API Key Setup

To run this project locally, you need to add your Google Maps API key:

### 1. Get Your API Key
- Go to [Google Cloud Console](https://console.cloud.google.com/)
- Create a new project
- Enable these APIs:
  - Maps SDK for Android
  - Maps SDK for iOS
  - Maps JavaScript API
- Go to **Credentials** → **+ Create Credentials** → **API Key**
- Copy your API key

### 2. Create `.env` file in project root
```
GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

### 3. Add to your local files (DO NOT COMMIT):

**Web** (`web/index.html`):
```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY"></script>
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_API_KEY"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>GMSApiKey</key>
<string>YOUR_API_KEY</string>
```

### 4. Run the app
```bash
flutter run
```

**⚠️ IMPORTANT:** Never commit your API key to GitHub!
