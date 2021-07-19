$PortalAddress = 'gpportal.domain.com'
$MSIFileName = 'GlobalProtect64-5.2.7.msi'
$MSISwitches = '/quiet /norestart'

$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Path

$InstallProcess = Start-Process -FilePath "msiexec" -ArgumentList ("/i " + [char]34 + $ScriptPath + "\" + $MSIFileName + [char]34 + " " + $MSISwitches) -PassThru -Wait

New-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup' -Name 'Portal' -Value $PortalAddress -PropertyType String -Force | Out-Null

#Register PLAP provider
Start-Process -FilePath "$env:ProgramFiles\Palo Alto Networks\GlobalProtect\PanGPS.exe" -ArgumentList "-registerplap" -Wait

Write-Host ("Installation completed, exiting with last return code (" + $InstallProcess.ExitCode + ")")
Exit $InstallProcess.ExitCode