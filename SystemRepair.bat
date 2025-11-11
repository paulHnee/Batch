@echo off
color 7
echo Systemdateien werden überprüft und das Wartungs-Tool DISM wird ausgeführt...

:sfc
echo Schritt 1: Starte sfc /scannow
sfc /scannow
if %errorlevel% neq 0 (
    :: Nur diese eine Zeile in Rot ausgeben
    powershell -command "Write-Host 'SFC hat einen Fehler festgestellt.' -ForegroundColor Red"
    set /p retry_sfc="Möchten Sie SFC erneut starten? (j/n): "
    if /i "%retry_sfc%"=="j" (
        goto :sfc
    ) else (
        echo SFC wird übersprungen.
    )
)

:dism_scanhealth
echo Schritt 2: Starte DISM /scanhealth
dism /online /cleanup-image /scanhealth
if %errorlevel% neq 0 (
    powershell -command "Write-Host 'DISM /scanhealth hat einen Fehler festgestellt.' -ForegroundColor Red"
    set /p retry_scan="Möchten Sie DISM /scanhealth erneut starten? (j/n): "
    if /i "%retry_scan%"=="j" (
        goto :dism_scanhealth
    ) else (
        echo DISM /scanhealth wird übersprungen.
    )
)

:dism_checkhealth
echo Schritt 3: Starte DISM /checkhealth
dism /online /cleanup-image /checkhealth
if %errorlevel% neq 0 (
    powershell -command "Write-Host 'DISM /checkhealth hat einen Fehler festgestellt.' -ForegroundColor Red"
    set /p retry_check="Möchten Sie DISM /checkhealth erneut starten? (j/n): "
    if /i "%retry_check%"=="j" (
        goto :dism_checkhealth
    ) else (
        echo DISM /checkhealth wird übersprungen.
    )
)

:dism_restorehealth
echo Schritt 4: Starte DISM /restorehealth
dism /online /cleanup-image /restorehealth
if %errorlevel% neq 0 (
    powershell -command "Write-Host 'DISM /restorehealth hat einen Fehler festgestellt.' -ForegroundColor Red"
    set /p retry_restore="Möchten Sie DISM /restorehealth erneut starten? (j/n): "
    if /i "%retry_restore%"=="j" (
        goto :dism_restorehealth
    ) else (
        echo DISM /restorehealth wird übersprungen.
    )
)
color B
echo Alle Überprüfungen und Reparaturen sind abgeschlossen.
pause
