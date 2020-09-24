@ECHO OFF

%SystemRoot%\SysNative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass .\InstallGlobalProtect.ps1

EXIT /B %ERRORLEVEL%