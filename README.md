# 🎲 Ludo & Multi Casual Games Bundle (Flutter)

A multi-board casual gaming bundle built with **Flutter 3**, featuring offline Pass & Play, smart AI, Google AdMob banner & match-end interstitial video monetization, and automated cloud APK building.

---

## 🎮 Included Games
1. **Classic Ludo (4 Tokens):** Full traditional 15x15 board with 2-4 players (Pass & Play offline or vs Computer AI). Safe star squares, token capturing, and home lane.
2. **Ludo Quick Rush (2 Tokens):** High-speed 5-minute variant where each player has 2 tokens. Fast, exciting, and highly addictive.
3. **Snakes & Ladders (1-100):** Classic 10x10 zigzag board with authentic snakes, ladders, smooth step-by-step animations, and exact roll to win.
4. **Tic-Tac-Toe:** Quick 1-minute brain casual game with unbeatable AI option, pass & play, score counter, and winning line highlights.

---

## 💰 AdMob Monetization Policy (Zero Gameplay Popups)
- **Bottom Banner Ad:** Non-intrusive banner ad docked at the bottom of the screen.
- **Match-End Interstitial Video Ad:** Strict policy — **no ads pop up during game sessions**. Interstitial/video ads trigger exclusively on the Victory Dialog when a match ends.
- **Preconfigured Test IDs (Ready for Testing):**
  - Android Banner: `ca-app-pub-3940256099942544/6300978111`
  - Android Interstitial: `ca-app-pub-3940256099942544/1033173712`
  - Android Rewarded: `ca-app-pub-3940256099942544/5224354917`

---

## ☁️ How to Build APK with GitHub Actions (No local SDK needed)
Since Flutter/Java are not configured locally on Windows, you don't need to install 5GB of tools.
1. Push this folder to your GitHub repository:
   ```bash
   git init
   git add .
   git commit -m "Initial commit of Ludo Multi Games"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/ludo_multi_games.git
   git push -u origin main
   ```
2. Open your GitHub repo -> click the **Actions** tab.
3. The **"Build Android APK and AAB Bundle"** workflow will automatically build your APK.
4. Download the ready-to-install `app-release.apk` directly to your phone or PC!

---

## 💻 Local Build (If Flutter & Android SDK are installed)
```bash
flutter pub get
flutter run
flutter build apk --release
flutter build appbundle --release
```
