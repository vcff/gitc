# prerequsity is that on remote server is one username "nt" defined with same "password"
# "nt" user is part of "remote user" group which allows remote connection"
# tested with virtualbox server machines on it
# its not based on build for simplicity

# Error handling to make sure file is present
$ErrorActionPreference = "Stop"
try {
   if(Import-Csv -Path .\serverlist.csv) {
      Write-Output "serverlist.csv found"
   }
}catch {
   Write-Output "serverlist.csv not found"
   $_.Exception
}
$servers = Import-Csv -Path .\serverlist.csv
$user = "$computername\nt"
# password is starred/hidden instead of plain text
$password = Read-Host 'What is your password?' -AsSecureString
$cred = [PSCredential]::new($user,$password)
# this goes thru each server read from the CSV. By default, first row is treated as header.
foreach ($line in $servers)
{ 
    # When calling the computername, you refer the line, and to the particular column name. here we assume it is called "ServerName"
    $result = Invoke-Command -Computername $line.ServerName -Credential $cred -ScriptBlock {
        $Hostname = (Hostname)
	# to add another layer to make sure that script only process server versions based on Major,Minor,Type (BuildNumbers) skipped for simplicity
	#Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
	$CurrentMajorVersionNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMajorVersionNumber).CurrentMajorVersionNumber
        $CurrentMinorVersionNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMinorVersionNumber).CurrentMinorVersionNumber
        $InstallationType = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name InstallationType).InstallationType
	$ProductName = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
        #Windows Server 2016 / 2019 / 2022
	If ($CurrentMajorVersionNumber -eq "10" -and $CurrentMinorVersionNumber -eq "0" -and $InstallationType -eq "Server")  {
            $TimeOutValue = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\disk" -Name TimeOutValue).TimeOutValue
		    Write-Host ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
		    Write-Host "Given Windows Version is "$ProductName" located on "$Hostname  " " 
		    Write-Host "Queried value "TimeOutValue" from registry Key for "HKLM:\SYSTEM\CurrentControlSet\Services\disk" is "$TimeOutValue" " 
            }
        # Windows Server 2012 and R2 version
        ElseIf (($CurrentMajorVersionNumber -eq "6" -and $CurrentMinorVersionNumber -eq "2" -and $InstallationType -eq "Server") -Or ($CurrentMajorVersionNumber -eq "6" -and $CurrentMinorVersionNumber -eq "3" -and $InstallationType -eq "Server")) {
            $TimeOutValue = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\disk" -Name TimeOutValue).TimeOutValue
		    Write-Host ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
		    Write-Host "Given Windows Version is "$ProductName" located on "$Hostname  " " 
		    Write-Host "Queried value "TimeOutValue" from registry Key for "HKLM:\SYSTEM\CurrentControlSet\Services\disk" is "$TimeOutValue" " 
            }
        Else {
        Write-Host "Given Windows Version is "$ProductName" located on "$Hostname and not Server edition" " 
        }
    } 
    $result | Export-Csv -Path .\extracted_keys.csv -Delimiter ';' -NoTypeInformation
