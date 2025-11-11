@echo off
setlocal enabledelayedexpansion

REM Ausgabedatei definieren
set "OUTPUT_FILE=I:\ITSZ\Azubi\pc_mac_info.txt"

REM PC-Namen abrufen
set "PC_NAME=%COMPUTERNAME%"

REM MAC-Adresse des WLAN-Adapters ermitteln mit PowerShell
for /f "usebackq tokens=*" %%a in (`powershell -Command "$output = ipconfig /all; $found = $false; foreach($line in $output) { if($line -match 'Drahtlos-LAN-Adapter WLAN:') { $found = $true } if($found -and $line -match 'Physische Adresse.*:\s*(.*)') { $mac = $matches[1] -replace '-',''; Write-Output $mac.Trim(); break } }"`) do (
    set "MAC=%%a"
)

:found
REM Wenn keine MAC-Adresse gefunden wurde
if "!MAC!"=="" (
    echo Fehler: Keine MAC-Adresse gefunden!
    pause
    exit /b 1
)

REM In Datei schreiben (immer ans Ende anfügen)
(
    echo #%PC_NAME%
    echo !MAC! Cleartext-Password :="!MAC!"
    echo.
) >> "%OUTPUT_FILE%"

echo Daten erfolgreich gespeichert in: %OUTPUT_FILE%
echo PC-Name: %PC_NAME%
echo MAC-Adresse: !MAC!

endlocal
exit /b 0