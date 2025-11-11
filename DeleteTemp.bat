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

echo Starte Datentraegerbereinigung und loesche TEMP-Dateien...

:: Schritt 1: Datenträgerbereinigung ausführen
powershell -command "Write-Host 'Schritt 1: Starte Datentraegerbereinigung...' -ForegroundColor Cyan"
cleanmgr /sagerun:1

:: Schritt 2: System-TEMP-Dateien löschen
powershell -command "Write-Host 'Schritt 2: Loesche System-TEMP-Dateien...' -ForegroundColor Cyan"
del /s /q /f %SystemRoot%\Temp\* 2>nul
for /d %%p in (%SystemRoot%\Temp\*) do rd /s /q "%%p" 2>nul

:: Schritt 3: Benutzer-TEMP-Dateien löschen
powershell -command "Write-Host 'Schritt 3: Loesche Benutzer-TEMP-Dateien...' -ForegroundColor Cyan"
del /s /q /f "%TEMP%\*" 2>nul
for /d %%p in ("%TEMP%\*") do rd /s /q "%%p" 2>nul

:: Schritt 4: Windows Prefetch löschen (optional)
powershell -command "Write-Host 'Schritt 4: Loesche Prefetch-Dateien...' -ForegroundColor Cyan"
del /s /q /f %SystemRoot%\Prefetch\* 2>nul

:: Abschlussmeldung
powershell -command "Write-Host 'Datentraegerbereinigung und Loeschung der TEMP-Dateien abgeschlossen.' -ForegroundColor Green"
pause
