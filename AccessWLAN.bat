@echo off
REM ========================================
REM Auto-Connect to WLAN Script
REM ========================================
REM This script automatically connects to a WiFi network
REM Edit the SSID and PASSWORD variables below

REM Check for administrator rights
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNUNG] Dieses Script sollte als Administrator ausgefuehrt werden!
    echo Rechtsklick -^> "Als Administrator ausfuehren"
    echo.
    pause
    exit /b 1
)

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
echo Netzwerk: %SSID%
echo Authentifizierung: %AUTH%
echo Verschluesselung: %ENCRYPTION%
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
echo Fuege WiFi-Profil hinzu...
netsh wlan add profile filename="%XML_FILE%" user=current

if %errorlevel% neq 0 (
    echo [FEHLER] WiFi-Profil konnte nicht hinzugefuegt werden.
    echo Moegliche Ursachen:
    echo - Script muss als Administrator ausgefuehrt werden
    echo - Ungueltige Konfiguration
    goto :cleanup
)

echo WiFi-Profil erfolgreich hinzugefuegt.
echo.

REM Connect to the network
echo Verbinde mit %SSID%...
netsh wlan connect name="%SSID%" 2>nul

if %errorlevel% neq 0 (
    echo.
    echo [WARNUNG] Standortberechtigungen erforderlich!
    echo.
    echo Windows 11 benoetigt Standortdienste fuer WLAN-Verbindungen.
    echo.
    echo Bitte aktiviere Standortdienste:
    echo 1. Oeffne Einstellungen (wird automatisch geoeffnet)
    echo 2. Gehe zu: Datenschutz ^& Sicherheit -^> Standort
    echo 3. Aktiviere "Standortdienste"
    echo 4. Aktiviere "Apps den Zugriff auf Ihren Standort erlauben"
    echo.
    echo Oeffne Standort-Einstellungen...
    start ms-settings:privacy-location
    echo.
    echo Druecke eine Taste nachdem du Standortdienste aktiviert hast...
    pause >nul
    echo.
    echo Versuche erneut zu verbinden...
    netsh wlan connect name="%SSID%"
    if %errorlevel% neq 0 (
        echo.
        echo [FEHLER] Verbindung fehlgeschlagen.
        echo Moegliche Ursachen:
        echo - Standortdienste noch nicht aktiviert
        echo - Netzwerk ist nicht in Reichweite
        echo - WLAN ist ausgeschaltet
        echo - Falsches Passwort
        goto :cleanup
    )
)

echo.
echo [ERFOLG] Verbunden mit %SSID%!
echo.

REM Wait a moment and check connection status
timeout /t 3 /nobreak >nul
echo Aktueller WiFi-Status:
echo ----------------------
netsh wlan show interfaces | findstr /C:"SSID" /C:"State" /C:"Signal"

:cleanup
REM Clean up temporary XML file
if exist "%XML_FILE%" del /f /q "%XML_FILE%" >nul 2>&1

echo.
echo ========================================
echo Script abgeschlossen.
echo ========================================
pause
