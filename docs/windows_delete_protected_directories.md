# delete protected windows directory

## English

```bash
# PowerShell as Admin
takeown /f "<directory>" /r /d y 
icacls "<directory>" /grant Administrators:F /t 
Remove-Item -Path "<directory>" -Recurse -Force

```

## German

```bash
# PowerShell as Admin
takeown /f "<directory>" /r /d j 
icacls "<directory>" /grant Administratoren:F /t 
Remove-Item -Path "<directory>" -Recurse -Force

```
