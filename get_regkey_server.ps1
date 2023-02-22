<#
.Synopsis
   Gathering key value from registry 
.DESCRIPTION
   Gathering key value from registry from specific OS Win releases based on server list hostnames provided in csv file
.EXAMPLE
  ./get_regkey_server.ps1
.NOTES
  - prerequsity is that on remote server(s) is defined username "nt" with password and part of remoter membership group for remote connections
#>

# Error handling to make sure file is present
$ErrorActionPreference = "Stop"
try {
	if(Import-Csv -Path .\servers.csv) {
		Write-Output "servers.csv found"
   }
}	catch {
	Write-Output "servers.csv not found"
	$_.Exception
}

$servers = Import-Csv -Path .\servers.csv
#$user = "$computername\nt"
# starred password
$password = Read-Host 'What is your password?' -AsSecureString
#$cred = [PSCredential]::new($user,$password)
foreach ($line in $servers)
{ 
	try {
	$result = Invoke-Command -Computername $line.ServerName -ScriptBlock  {
		$Hostname = (Hostname)
		# to add another layer to make sure that script only process server versions based on Major,Minor,Type (BuildNumbers) skipped for simplicity
		Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
		# if something is wrong with registry, it will not proceed to show anything "not tested yet"
		$CurrentMajorVersionNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMajorVersionNumber -EA stop).CurrentMajorVersionNumber
		$CurrentMinorVersionNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMinorVersionNumber -EA stop).CurrentMinorVersionNumber
		$InstallationType = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name InstallationType -EA stop).InstallationType
		$ProductName = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName -EA stop).ProductName
		#Windows Server 2016 / 2019 / 2022
		If ($CurrentMajorVersionNumber -eq "10" -and $CurrentMinorVersionNumber -eq "0" -and $InstallationType -eq "Server")  {
			$TimeOutValue = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\disk" -Name TimeOutValue).TimeOutValue
			Write-Host "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
			Write-Host "Given Windows Version is "$ProductName" located on "$Hostname  " " 
			Write-Host "Queried value "TimeOutValue" from registry Key for "HKLM:\SYSTEM\CurrentControlSet\Services\disk" is "$TimeOutValue" "  
			} 
		# Windows Server 2012 and R2 version
		ElseIf (($CurrentMajorVersionNumber -eq "6" -and $CurrentMinorVersionNumber -eq "2" -and $InstallationType -eq "Server") -Or ($CurrentMajorVersionNumber -eq "6" -and $CurrentMinorVersionNumber -eq "3" -and $InstallationType -eq "Server")) {
			$TimeOutValue = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\disk" -Name TimeOutValue).TimeOutValue
			Write-Host "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
			Write-Host "Given Windows Version is "$ProductName" located on "$Hostname  " " 
			Write-Host "Queried value "TimeOutValue" from registry Key for "HKLM:\SYSTEM\CurrentControlSet\Services\disk" is "$TimeOutValue" "  
			} 
		Else {
		Write-Host "Given Windows Version is "$ProductName" located on "$Hostname and not Server edition" " 
		# EA action will make sure thats if in defined server list one of server is online, script will continue with another one
			} 
		}
	} #-ErrorAction SilentlyContinue 
	# if one server is not "online" available during connection exception is thrown 
	catch [System.Management.Automation.Remoting.PSRemotingTransportException]  {
	Write-Host " "$_.Exception" " -ForegroundColor Red
	}
	$result 
}
