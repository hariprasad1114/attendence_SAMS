@echo off
echo ========================================
echo   SAMS App - Quick Setup Guide
echo ========================================
echo.

echo Flutter is not installed on your system.
echo Here are your options to run the SAMS app:
echo.

echo OPTION 1: Android Studio (RECOMMENDED)
echo ======================================
echo 1. Download: https://developer.android.com/studio
echo 2. Install with default settings
echo 3. Open Android Studio
echo 4. Install Flutter plugin (File ^> Settings ^> Plugins)
echo 5. Open project: %CD%
echo 6. Click the green play button
echo.

echo OPTION 2: Manual Flutter Install
echo ================================
echo 1. Download: https://flutter.dev/docs/get-started/install/windows
echo 2. Extract to: C:\flutter\
echo 3. Add C:\flutter\bin to PATH
echo 4. Restart Command Prompt
echo 5. Run: flutter pub get
echo 6. Run: flutter run
echo.

echo OPTION 3: VS Code
echo =================
echo 1. Download: https://code.visualstudio.com/
echo 2. Install Flutter extension
echo 3. Open folder: %CD%
echo 4. Press F5 to run
echo.

echo Current project location: %CD%
echo.

echo IMPORTANT: Make sure XAMPP is running!
echo - Apache service should be started
echo - MySQL service should be started
echo - Backend API is at: http://localhost/backend_api
echo.

echo Default login credentials:
echo Email: admin@sams.com
echo Password: password
echo Role: admin
echo.

pause
