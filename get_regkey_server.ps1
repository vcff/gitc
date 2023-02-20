# prerequsity is that on remote server is one username "nt" defined with same "password"
# "nt" user is part of "remote user" group which allows remote connection"
# tested with virtualbox server machines on it
# its not based on build for simplicity

# Error handling to make sure file is present
$ErrorActionPreference = "Stop"
try {
   if(Import-Csv -Path .\servers.csv) {
      Write-Output "servers.csv found"
   }
}  catch {
   Write-Output "servers.csv not found"
   $_.Exception
}

$servers = Import-Csv -Path .\servers.csv
$user = "$computername\nt"
$password = Read-Host 'What is your password?' -AsSecureString
$cred = [PSCredential]::new($user,$password)
foreach ($line in $servers)
{ 
    try {
	$result = Invoke-Command -Computername $line.ServerName -Credential $cred -ScriptBlock  {
        $Hostname = (Hostname)
        #Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        $CurrentMajorVersionNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMajorVersionNumber -EA stop).CurrentMajorVersionNumber
        $CurrentMinorVersionNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMinorVersionNumber -EA stop).CurrentMinorVersionNumber
        $InstallationType = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name InstallationType -EA stop).InstallationType
        $ProductName = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName -EA stop).ProductName
        #Windows Server 2016 / 2019 / 2022
        If ($CurrentMajorVersionNumber -eq "10" -and $CurrentMinorVersionNumber -eq "0" -and $InstallationType -eq "Server")  {
		$TimeOutValue = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\disk" -Name TimeOutValue).TimeOutValue
		Write-Host "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
		Write-Host "Given Windows Version is "$ProductName" located on "$Hostname  " " 
		Write-Host "Queried value "TimeOutValue" from registry Key for "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" is "$TimeOutValue" "  
		} 
        # Windows Server 2012 and R2 version
        ElseIf (($CurrentMajorVersionNumber -eq "6" -and $CurrentMinorVersionNumber -eq "2" -and $InstallationType -eq "Server") -Or ($CurrentMajorVersionNumber -eq "6" -and $CurrentMinorVersionNumber -eq "3" -and $InstallationType -eq "Server")) {
                 $TimeOutValue = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\disk" -Name TimeOutValue).TimeOutValue
		 Write-Host "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
		 Write-Host "Given Windows Version is "$ProductName" located on "$Hostname  " " 
		 Write-Host "Queried value "TimeOutValue" from registry Key for "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" is "$TimeOutValue" "  
		} 
        Else {
        Write-Host "Given Windows Version is "$ProductName" located on "$Hostname and not Server edition" " 
		# EA action will make sure thats if in defined server list one of server is online, script will continue with another one
	     } 
	}
    } #-ErrorAction SilentlyContinue 
    catch [System.Management.Automation.Remoting.PSRemotingTransportException]  {
    Write-Host " "$_.Exception" " -ForegroundColor Red
    }
    $result 
}
