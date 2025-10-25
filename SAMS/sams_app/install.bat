@echo off
echo ========================================
echo   Smart Attendance Management System
echo           Installation Script
echo ========================================
echo.

echo Checking prerequisites...

:: Check if XAMPP is installed
if not exist "C:\xampp\xampp-control.exe" (
    echo ERROR: XAMPP not found at C:\xampp\
    echo Please install XAMPP from https://www.apachefriends.org/
    pause
    exit /b 1
)

echo ✅ XAMPP found

:: Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found in PATH
    echo Please install Flutter from https://flutter.dev/
    pause
    exit /b 1
)

echo ✅ Flutter found

echo.
echo Starting XAMPP services...
start "" "C:\xampp\xampp-control.exe"

echo.
echo Waiting for XAMPP to start...
timeout /t 5 /nobreak >nul

echo.
echo Setting up database...
echo Please open phpMyAdmin (http://localhost/phpmyadmin) and import the database schema:
echo File: database\sams_schema.sql
echo.
pause

echo.
echo Copying API files to XAMPP...
if not exist "C:\xampp\htdocs\backend_api" (
    mkdir "C:\xampp\htdocs\backend_api"
)

xcopy "backend_api\*" "C:\xampp\htdocs\backend_api\" /E /Y /Q
echo ✅ API files copied

echo.
echo Installing Flutter dependencies...
cd sams_app
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to install Flutter dependencies
    pause
    exit /b 1
)
echo ✅ Flutter dependencies installed

echo.
echo ========================================
echo           Installation Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Import database schema in phpMyAdmin
echo 2. Test API endpoints: http://localhost/backend_api/test_api.php
echo 3. Run Flutter app: flutter run
echo.
echo Default Admin Credentials:
echo Email: admin@sams.com
echo Password: password
echo.
echo API Base URL: http://localhost/backend_api
echo.
pause
