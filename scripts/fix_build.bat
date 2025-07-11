@echo off
echo Fixing Flutter build issues...

echo Stopping all Gradle daemons...
cd /d "%~dp0..\android"
call gradlew.bat --stop

echo Cleaning Flutter project...
cd /d "%~dp0.."
call flutter clean

echo Cleaning Android project...
cd /d "%~dp0..\android"
call gradlew.bat clean

echo Deleting problematic files...
cd /d "%~dp0.."
del /f /q build\app\outputs\flutter-apk\app-debug.apk 2>nul
rmdir /s /q build\app\intermediates 2>nul

echo Killing any remaining Java processes (optional - uncomment if needed)
REM taskkill /f /im java.exe 2>nul

echo Build fix complete. You can now try building again.
pause
