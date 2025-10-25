@echo off
echo ========================================
echo   Flutter Installation Helper
echo ========================================
echo.

echo This script will help you install Flutter and run the SAMS app.
echo.

echo Step 1: Download Flutter
echo ------------------------
echo 1. Go to: https://flutter.dev/docs/get-started/install/windows
echo 2. Download the latest stable release
echo 3. Extract to C:\flutter\
echo.
echo Step 2: Add Flutter to PATH
echo ---------------------------
echo 1. Press Win + R, type sysdm.cpl
echo 2. Click "Environment Variables"
echo 3. Under "System Variables", find "Path" and click "Edit"
echo 4. Click "New" and add: C:\flutter\bin
echo 5. Click "OK" on all dialogs
echo.
echo Step 3: Restart Command Prompt and run:
echo    flutter doctor
echo    flutter pub get
echo    flutter run
echo.

echo Alternative: Use Android Studio
echo ------------------------------
echo 1. Download Android Studio: https://developer.android.com/studio
echo 2. Install Flutter plugin
echo 3. Open this project folder
echo 4. Click the green play button
echo.

echo Alternative: Use VS Code
echo ------------------------
echo 1. Download VS Code: https://code.visualstudio.com/
echo 2. Install Flutter extension
echo 3. Open this project folder
echo 4. Press F5 to run
echo.

echo Current project location:
echo %CD%
echo.

pause
