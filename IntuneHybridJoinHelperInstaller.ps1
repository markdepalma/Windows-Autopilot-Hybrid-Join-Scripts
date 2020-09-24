#####################Variables#######################
$ScriptPath = 'C:\Scripts'
$ScriptName = 'IntuneHybridJoinHelper'
#####################################################




#'IntuneHybridJoinHelper.ps1' script payload
$ScriptPayload = '$GPCachePath = "$env:windir\System32\GroupPolicy\DataStore"

#Only run if machine group policy has never been synced and cache has not been created
If ((Test-Path -Path $GPCachePath) -eq $false) {
	#Start machine gpupdate
	Start-Process -FilePath gpupdate.exe -ArgumentList "/Target:Computer" -Wait
	
	#Get current logged on interactive session
	$CurrentSession = Get-CimInstance -ClassName Win32_ComputerSystem
	
	#Start task 20 seconds from now
	$TaskDate = (Get-Date).AddSeconds(20)
	
	#Create self-deleting task to run user/machine gpupdate as the current user
	$a = New-ScheduledTaskAction -Execute "gpupdate.exe"
	$b = New-ScheduledTaskTrigger -At $TaskDate -Once
	$b.EndBoundary = $TaskDate.AddSeconds(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
	$c = New-ScheduledTaskPrincipal -UserId $CurrentSession.UserName -LogonType Interactive
	$d = New-ScheduledTaskSettingsSet
	$d.DisallowStartIfOnBatteries = $false
	$d.StopIfGoingOnBatteries = $false
	$d.DeleteExpiredTaskAfter = "PT0S"
	$e = New-ScheduledTask -Action $a -Trigger $b -Principal $c -Settings $d
	Register-ScheduledTask -InputObject $e -TaskName "UserGpupdate" -Force
	
	#Re-run hybrid device join in case of previous failure at logon
	Get-ScheduledTask -TaskName "Automatic-Device-Join" | Start-ScheduledTask
}'

#Create script folder
New-Item -Type Directory -Path $ScriptPath -Force

#Remove 'Authenticated Users' from folder permissions to prevent malicious code execute in LOCAL SYSTEM context
$FolderAcl = Get-Acl -Path $ScriptPath
$FolderAcl.SetAccessRuleProtection($true, $true)
Set-Acl -Path $ScriptPath -AclObject $FolderAcl
$FolderAcl = Get-Acl -Path $ScriptPath
$FolderAcl.Access | Where {$_.IdentityReference -eq 'NT AUTHORITY\Authenticated Users'} | ForEach-Object {
	$FolderAcl.RemoveAccessRuleAll($_)
}
Set-Acl -Path $ScriptPath -AclObject $FolderAcl

#Create 'IntuneHybridJoinHelper.ps1' for scheduled task
$ScriptPayload | Out-File -FilePath "$ScriptPath\$ScriptName.ps1" -Force

#Create 'IntuneHybridJoinHelper' scheduled task 
$a = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-ExecutionPolicy Bypass -File ""$ScriptPath\$ScriptName.ps1"""
$b = New-ScheduledTaskTrigger -AtLogOn
$c = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$d = New-ScheduledTaskSettingsSet
$d.DisallowStartIfOnBatteries = $false
$d.StopIfGoingOnBatteries = $false
$e = New-ScheduledTask -Action $a -Trigger $b -Principal $c -Settings $d
Register-ScheduledTask -InputObject $e -TaskName $ScriptName -TaskPath "\Intune Helpers" -Force