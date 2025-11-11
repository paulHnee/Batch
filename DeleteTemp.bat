@echo off
color 7
echo Starte Datentraegerbereinigung und loesche TEMP-Dateien...

:: Schritt 1: Datenträgerbereinigung ausführen
powershell -command "Write-Host 'Schritt 1: Starte Datentraegerbereinigung...' -ForegroundColor Cyan"
cleanmgr /sagerun:1

:: Schritt 2: System-TEMP-Dateien löschen
powershell -command "Write-Host 'Schritt 2: Loesche System-TEMP-Dateien...' -ForegroundColor Cyan"
del /s /q %SystemRoot%\Temp\*

:: Schritt 3: Benutzer-TEMP-Dateien löschen
powershell -command "Write-Host 'Schritt 3: Loesche Benutzer-TEMP-Dateien...' -ForegroundColor Cyan"
del /s /q "%TEMP%\*"

:: Abschlussmeldung
powershell -command "Write-Host 'Datentraegerbereinigung und Loeschung der TEMP-Dateien abgeschlossen.' -ForegroundColor Green"
pause
