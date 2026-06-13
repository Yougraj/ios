# YouTube WebView — iOS App (iPhone 7)

A native WKWebView wrapper for youtube.com, built with Swift.
GitHub Actions builds the unsigned IPA automatically on a free macOS runner.

---

## How to get your IPA (from Linux)

### Step 1 — Create a GitHub repository

Go to https://github.com/new and create a new **public** repository.
Name it anything, e.g. `youtube-ios-app`.

### Step 2 — Push this code

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/youtube-ios-app.git
git push -u origin main
```

### Step 3 — Watch it build

1. Go to your repo on GitHub
2. Click the **Actions** tab
3. You'll see "Build YouTube IPA" running automatically
4. Wait ~5 minutes for it to finish

### Step 4 — Download your IPA

1. Click the completed workflow run
2. Scroll down to **Artifacts**
3. Click **YouTubeApp-IPA** to download the zip
4. Unzip it — inside is `YouTubeApp.ipa`

---

## Install on your iPhone 7

Since the IPA is unsigned, use one of these tools to sideload it:

### AltStore (recommended, free)
1. Install AltStore on your PC/Mac: https://altstore.io
2. Connect iPhone via USB
3. Drag `YouTubeApp.ipa` onto AltStore → Install
4. Re-sign every 7 days (free Apple ID limit)

### Sideloadly (easier on Windows/Mac)
1. Download: https://sideloadly.io
2. Connect iPhone, drag IPA in, click Start

### TrollStore (iPhone 7 on iOS 15.x — permanent, no re-signing)
If your iPhone 7 is on iOS 14–16.6.1, TrollStore can install it permanently:
https://ios.cfw.guide/installing-trollstore/

---

## Project structure

```
.
├── .github/
│   └── workflows/
│       └── build-ipa.yml       ← GitHub Actions workflow
└── YouTubeApp/
    ├── YouTubeApp.xcodeproj/
    │   └── project.pbxproj
    └── YouTubeApp/
        ├── AppDelegate.swift   ← App entry point
        ├── ViewController.swift ← WKWebView loading youtube.com
        └── Info.plist
```

## Features
- Loads youtube.com with real iPhone Safari user-agent
- Inline video playback
- Red progress bar while loading
- Pull-to-refresh
- Offline error page with retry button
- Portrait + landscape support
