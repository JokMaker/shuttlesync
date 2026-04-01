# ShuttleSync 🚍

ShuttleSync is a simple, judge-friendly Flutter app with a pink/yellow aesthetic and 4 screens:

1. **Splash** (3s auto → app)
2. **Home** dashboard (refreshes bus cards every 15s)
3. **Live Track** (map/route + ETA + alert banner + ETA graph)
4. **My Stops** (personalization + toggles persisted locally)

## Demo mode vs server mode

By default, the app runs in **demo mode** (built-in sample bus data) so it works even without a backend.

If you have a FastAPI server running, configure the base URL at build time using:

`SHUTTLESYNC_API_BASE_URL`

The app expects:

- `GET /api/buses`

## Run it

```zsh
flutter pub get
flutter run
```

## Google Maps setup (optional for the live map)

The Live Track screen includes a Google Map. If you don’t set API keys yet, the screen still runs and shows a graceful placeholder.

### Android

Add your Maps key in `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
	<!-- ... -->
	<meta-data
		android:name="com.google.android.geo.API_KEY"
		android:value="YOUR_API_KEY_HERE" />
</application>
```

### iOS

Add your API key in `ios/Runner/AppDelegate.swift` (or via `GMSServices.provideAPIKey`).

## Notes for demo day

- Home refreshes every **15 seconds**.
- “My Stops” toggles + stops are persisted using `shared_preferences`.
- If your backend isn’t reachable, the app falls back to demo data (no crash).
