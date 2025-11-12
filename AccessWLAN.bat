@echo off
REM ========================================
REM Auto-Connect to WLAN Script
REM ========================================
REM This script automatically connects to a WiFi network
REM Edit the SSID and PASSWORD variables below

REM === CONFIGURATION ===
REM Set your WiFi network name (SSID)
set "SSID=Geraete"

REM Set your WiFi password
set "PASSWORD=1357924680"

REM Set authentication type (WPA3-Personal)
REM Options: open, WPA2PSK, WPA3SAE
set "AUTH=WPA2PSK"

REM Set encryption type (AES is required for WPA3)
REM Options: none, WEP, TKIP, AES
set "ENCRYPTION=AES"

REM =====================

echo.
echo ========================================
echo     WiFi Auto-Connect Script
echo ========================================
echo.
echo Connecting to: %SSID%
echo.

REM Create temporary XML profile file
set "PROFILE_NAME=%SSID%_Profile"
set "XML_FILE=%TEMP%\wifi_profile.xml"

REM Generate WiFi profile XML
(
echo ^<?xml version="1.0"?^>
echo ^<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1"^>
echo     ^<name^>%SSID%^</name^>
echo     ^<SSIDConfig^>
echo         ^<SSID^>
echo             ^<name^>%SSID%^</name^>
echo         ^</SSID^>
echo     ^</SSIDConfig^>
echo     ^<connectionType^>ESS^</connectionType^>
echo     ^<connectionMode^>auto^</connectionMode^>
echo     ^<MSM^>
echo         ^<security^>
echo             ^<authEncryption^>
echo                 ^<authentication^>%AUTH%^</authentication^>
echo                 ^<encryption^>%ENCRYPTION%^</encryption^>
echo                 ^<useOneX^>false^</useOneX^>
echo             ^</authEncryption^>
echo             ^<sharedKey^>
echo                 ^<keyType^>passPhrase^</keyType^>
echo                 ^<protected^>false^</protected^>
echo                 ^<keyMaterial^>%PASSWORD%^</keyMaterial^>
echo             ^</sharedKey^>
echo         ^</security^>
echo     ^</MSM^>
echo ^</WLANProfile^>
) > "%XML_FILE%"

REM Add the WiFi profile
echo Adding WiFi profile...
netsh wlan add profile filename="%XML_FILE%" user=current >nul 2>&1

if %errorlevel% neq 0 (
    echo [ERROR] Failed to add WiFi profile. Run as Administrator.
    goto :cleanup
)

echo WiFi profile added successfully.
echo.

REM Connect to the network
echo Connecting to %SSID%...
netsh wlan connect name="%SSID%" >nul 2>&1

if %errorlevel% neq 0 (
    echo [ERROR] Failed to connect. Make sure WiFi is enabled and network is in range.
    goto :cleanup
)

echo.
echo [SUCCESS] Connected to %SSID%!
echo.

REM Wait a moment and check connection status
timeout /t 3 /nobreak >nul
echo Current WiFi Status:
echo -------------------
netsh wlan show interfaces | findstr /C:"SSID" /C:"State" /C:"Signal"

:cleanup
REM Clean up temporary XML file
if exist "%XML_FILE%" del /f /q "%XML_FILE%" >nul 2>&1

echo.
echo ========================================
echo Script completed.
echo ========================================
pause
