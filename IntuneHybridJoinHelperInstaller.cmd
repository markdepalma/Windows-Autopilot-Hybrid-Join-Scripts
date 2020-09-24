@ECHO OFF

%SystemRoot%\SysNative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass .\IntuneHybridJoinHelperInstaller.ps1

EXIT /B %ERRORLEVEL%