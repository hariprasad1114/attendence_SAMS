@echo off
echo ========================================
echo   Smart Attendance Management System
echo           Flutter App Launcher
echo ========================================
echo.

echo Checking Flutter installation...

:: Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH
    echo.
    echo Please install Flutter first:
    echo 1. Download from https://flutter.dev/docs/get-started/install/windows
    echo 2. Extract to C:\flutter\
    echo 3. Add C:\flutter\bin to your PATH
    echo 4. Restart Command Prompt
    echo.
    echo Alternative: Use Android Studio or VS Code
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter found

echo.
echo Installing dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed

echo.
echo Checking for connected devices...
flutter devices

echo.
echo Starting SAMS App...
echo.
echo Default Login Credentials:
echo Email: admin@sams.com
echo Password: password
echo Role: admin
echo.
echo Make sure XAMPP is running with Apache and MySQL!
echo.

flutter run

pause
