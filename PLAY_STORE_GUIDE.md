# 🚀 Google Play Store Publishing Guide (Ludo Multi Games)

This guide walks you through the exact steps to publish **Ludo & Multi Casual Games Bundle** on the Google Play Console.

---

## 1. Switch from Test Ads to Live AdMob Production IDs

When you are ready to earn revenue from real users:
1. Open [lib/core/ads/ad_config.dart](file:///c:/Users/Vrijesh/anti%20backend/lib/core/ads/ad_config.dart).
2. Set `isTestMode = false;`.
3. Replace the placeholder IDs (`prodBannerId`, `prodInterstitialId`, `prodAppId`) with your real IDs from [Google AdMob](https://admob.google.com/).
4. Open [android/app/src/main/AndroidManifest.xml](file:///c:/Users/Vrijesh/anti%20backend/android/app/src/main/AndroidManifest.xml) and replace:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="YOUR_REAL_ADMOB_APP_ID"/>
   ```

---

## 2. Generate a Release Keystore (App Signing)

Google Play requires your app to be cryptographically signed.

Open PowerShell or Command Prompt and run:
```bash
keytool -genkey -v -keystore C:\Users\Vrijesh\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
*(Enter a secure password when prompted and remember it).*

Create a file named `android/key.properties` with:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:\\Users\\Vrijesh\\upload-keystore.jks
```

---

## 3. Build the Production Android App Bundle (.aab)

Google Play requires `.aab` (Android App Bundle) instead of `.apk` for new apps.

Run:
```bash
flutter build appbundle --release
```
The resulting file is saved at:
`build/app/outputs/bundle/release/app-release.aab`

*(Note: If you use the GitHub Actions CI/CD workflow, it automatically builds both the `.apk` and `.aab` for you!)*

---

## 4. Google Play Console Setup

1. **Create New App:**
   - App Name: `Ludo & Casual Board Games`
   - Default Language: English (or Hindi)
   - App or Game: **Game**
   - Free or Paid: **Free**

2. **Store Listing Assets:**
   - **App Icon:** 512 x 512 px (PNG 32-bit with alpha)
   - **Feature Graphic:** 1024 x 500 px (PNG/JPEG)
   - **Screenshots:** At least 2 phone screenshots (take them from your phone or using the web preview).

3. **Privacy Policy URL:**
   - Copy the contents of [PRIVACY_POLICY.md](file:///c:/Users/Vrijesh/anti%20backend/PRIVACY_POLICY.md) to a public URL (e.g. GitHub Gist, GitHub Pages, or Google Sites) and paste the link into the Play Console.

4. **Data Safety Form Answers:**
   - Does your app collect or share user data? **Yes** (Only what Google AdMob collects).
   - Collected Data: **Device or other IDs** (Ad ID for advertising/analytics purposes).
   - Is all data collected encrypted in transit? **Yes**.
   - Can users request data deletion? **Yes** (handled automatically by Google Play Services).

5. **Upload & Publish:**
   - Go to **Production** > **Create new release**.
   - Upload `app-release.aab`.
   - Add release notes (e.g., *"Initial release featuring Classic Ludo, Quick Rush, Snakes & Ladders, and Tic-Tac-Toe"*).
   - Review and rollout to production!
