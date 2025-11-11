@echo off
color 7

:: Admin-Rechte prüfen
net session >nul 2>&1
if %errorlevel% neq 0 (
    powershell -command "Write-Host 'Fehler: Dieses Skript erfordert Administrator-Rechte!' -ForegroundColor Red"
    powershell -command "Write-Host 'Bitte als Administrator ausfuehren.' -ForegroundColor Yellow"
    pause
    exit /b 1
)

:: Logdatei erstellen
set "LOGFILE=%USERPROFILE%\Desktop\SystemRepair_%date:~-4,4%%date:~-7,2%%date:~-10,2%_%time:~0,2%%time:~3,2%%time:~6,2%.log"
set "LOGFILE=%LOGFILE: =0%"

echo Systemdateien werden überprüft und das Wartungs-Tool DISM wird ausgeführt...
echo Logdatei: %LOGFILE%
echo Systemreparatur gestartet am %date% um %time% > "%LOGFILE%"
echo. >> "%LOGFILE%"

:sfc
echo Schritt 1: Starte sfc /scannow
echo [%time%] Starte sfc /scannow >> "%LOGFILE%"
sfc /scannow >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    :: Nur diese eine Zeile in Rot ausgeben
    powershell -command "Write-Host 'SFC hat einen Fehler festgestellt.' -ForegroundColor Red"
    echo [%time%] SFC Fehler (Errorlevel: %errorlevel%) >> "%LOGFILE%"
    set /p retry_sfc="Möchten Sie SFC erneut starten? (j/n): "
    if /i "%retry_sfc%"=="j" (
        goto :sfc
    ) else (
        echo SFC wird übersprungen.
        echo [%time%] SFC übersprungen >> "%LOGFILE%"
    )
) else (
    echo [%time%] SFC erfolgreich abgeschlossen >> "%LOGFILE%"
)

:dism_scanhealth
echo Schritt 2: Starte DISM /scanhealth
echo [%time%] Starte DISM /scanhealth >> "%LOGFILE%"
dism /online /cleanup-image /scanhealth >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    powershell -command "Write-Host 'DISM /scanhealth hat einen Fehler festgestellt.' -ForegroundColor Red"
    echo [%time%] DISM /scanhealth Fehler (Errorlevel: %errorlevel%) >> "%LOGFILE%"
    set /p retry_scan="Möchten Sie DISM /scanhealth erneut starten? (j/n): "
    if /i "%retry_scan%"=="j" (
        goto :dism_scanhealth
    ) else (
        echo DISM /scanhealth wird übersprungen.
        echo [%time%] DISM /scanhealth übersprungen >> "%LOGFILE%"
    )
) else (
    echo [%time%] DISM /scanhealth erfolgreich abgeschlossen >> "%LOGFILE%"
)

:dism_checkhealth
echo Schritt 3: Starte DISM /checkhealth
echo [%time%] Starte DISM /checkhealth >> "%LOGFILE%"
dism /online /cleanup-image /checkhealth >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    powershell -command "Write-Host 'DISM /checkhealth hat einen Fehler festgestellt.' -ForegroundColor Red"
    echo [%time%] DISM /checkhealth Fehler (Errorlevel: %errorlevel%) >> "%LOGFILE%"
    set /p retry_check="Möchten Sie DISM /checkhealth erneut starten? (j/n): "
    if /i "%retry_check%"=="j" (
        goto :dism_checkhealth
    ) else (
        echo DISM /checkhealth wird übersprungen.
        echo [%time%] DISM /checkhealth übersprungen >> "%LOGFILE%"
    )
) else (
    echo [%time%] DISM /checkhealth erfolgreich abgeschlossen >> "%LOGFILE%"
)

:dism_restorehealth
echo Schritt 4: Starte DISM /restorehealth
echo [%time%] Starte DISM /restorehealth >> "%LOGFILE%"
dism /online /cleanup-image /restorehealth >> "%LOGFILE%" 2>&1
if %errorlevel% neq 0 (
    powershell -command "Write-Host 'DISM /restorehealth hat einen Fehler festgestellt.' -ForegroundColor Red"
    echo [%time%] DISM /restorehealth Fehler (Errorlevel: %errorlevel%) >> "%LOGFILE%"
    set /p retry_restore="Möchten Sie DISM /restorehealth erneut starten? (j/n): "
    if /i "%retry_restore%"=="j" (
        goto :dism_restorehealth
    ) else (
        echo DISM /restorehealth wird übersprungen.
        echo [%time%] DISM /restorehealth übersprungen >> "%LOGFILE%"
    )
) else (
    echo [%time%] DISM /restorehealth erfolgreich abgeschlossen >> "%LOGFILE%"
)
color B
echo.
echo Alle Überprüfungen und Reparaturen sind abgeschlossen.
echo [%time%] Systemreparatur abgeschlossen >> "%LOGFILE%"
echo Vollstaendiges Log: %LOGFILE%
pause
