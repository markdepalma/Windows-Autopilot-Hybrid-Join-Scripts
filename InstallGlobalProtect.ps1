$PortalAddress = 'gpportal.domain.com'
$MSIFileName = 'GlobalProtect64-5.1.5.msi'
$MSISwitches = '/quiet /norestart'

$ScriptPath = Split-Path -Path $MyInvocation.MyCommand.Path

$InstallProcess = Start-Process -FilePath "msiexec" -ArgumentList ("/i " + [char]34 + $ScriptPath + "\" + $MSIFileName + [char]34 + " " + $MSISwitches) -PassThru -Wait

New-Item -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup' -Name 'PreLogonState' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup\PreLogonState' -Name 'LogonFlag' -Value 0 -PropertyType Dword -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup\PreLogonState' -Name 'LogonState' -Value 0 -PropertyType Dword -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup' -Name 'Portal' -Value $PortalAddress -PropertyType String -Force | Out-Null

#This is optional
New-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup' -Name 'ShowPrelogonButton' -Value 'yes' -PropertyType String -Force | Out-Null

New-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\PanSetup' -Name 'Prelogon' -Value '1' -PropertyType String -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect\Settings' -Name 'certificate-store-lookup' -Value 'user-and-machine' -PropertyType String -Force | Out-Null

Write-Host ("Installation completed, exiting with last return code (" + $InstallProcess.ExitCode + ")")
Exit $InstallProcess.ExitCode