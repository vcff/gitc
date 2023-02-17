# prerequsity is that on remote server is one username "nt" defined with same "password"
# "nt" user is part of "remote user" group which allows remote connection"
# tested with virtualbox server machines on it


$servers = Import-Csv -Path .\serverlist.csv
$user = "$computername\nt"
$password = Read-Host 'What is your password?' -AsSecureString
$cred = [PSCredential]::new($user,$password)
# this goes thru each server read from the CSV. By default, first row is treated as header.
foreach ($line in $servers)
{ 
    # When calling the computername, you refer the line, and to the particular column name. here we assume it is called "ServerName"
    $result = Invoke-Command -Computername $line.ServerName -Credential $cred -ScriptBlock {
        $Hostname = (Hostname)
		Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
		$CurrentMajorVersionNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMajorVersionNumber).CurrentMajorVersionNumber
        $CurrentMinorVersionNumber = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name CurrentMinorVersionNumber).CurrentMinorVersionNumber
        $InstallationType = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name InstallationType).InstallationType
		$ProductName = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ProductName).ProductName
        #Windows Server 2016 / 2019 / 2022
		If ($CurrentMajorVersionNumber -eq "10" -and $CurrentMinorVersionNumber -eq "0" -and $InstallationType -eq "Server")  {
            $TimeOutValue = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\disk" -Name TimeOutValue).TimeOutValue
		    Write-Host ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
		    Write-Host "Given Windows Version is "$ProductName" located on "$Hostname  " " 
		    Write-Host "Queried value "TimeOutValue" from registry Key for "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" is "$TimeOutValue" " 
            }
        # Windows Server 2012 and R2 version
        ElseIf (($CurrentMajorVersionNumber -eq "6" -and $CurrentMinorVersionNumber -eq "2" -and $InstallationType -eq "Server") -Or ($CurrentMajorVersionNumber -eq "6" -and $CurrentMinorVersionNumber -eq "3" -and $InstallationType -eq "Server")) {
            $TimeOutValue = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\disk" -Name TimeOutValue).TimeOutValue
		    Write-Host ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
		    Write-Host "Given Windows Version is "$ProductName" located on "$Hostname  " " 
		    Write-Host "Queried value "TimeOutValue" from registry Key for "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" is "$TimeOutValue" " 
            }
        Else {
        Write-Host "Given Windows Version is "$ProductName" located on "$Hostname and not Server edition" " 
        }
    } 
    $result | format-list
}



# Enable-PSRemoting
# Get-Item WSMan:\localhost\Client\TrustedHosts
# Set-Item WSMan:\localhost\Client\TrustedHosts -Value 'RemoteServerName'
# Set-Service WinRM -StartMode Automatic
# Get-WmiObject -Class win32_service | Where-Object {$_.name -like "WinRM"}
# Set-Item WSMan:localhost\client\trustedhosts -value *
# Get-Item WSMan:\localhost\Client\TrustedHosts
# New-PSSession -ComputerName WIN-915CS1PLH8B
# Test-WsMan WIN-915CS1PLH8B
# Invoke-Command –ComputerName WIN-915CS1PLH8B -ScriptBlock {Hostname}
# Invoke-Command –ComputerName WIN-915CS1PLH8B -Credential Administrator -ScriptBlock {Hostname}

#Windows Server 2012                                                 | MAJOR: 6  MINOR:2  BUILD:  9200
#Windows Server 2012 R2                                              | MAJOR: 6  MINOR:3  BUILD:  9600
#Windows Server 2016 RTM 2016-09-26                                  | MAJOR: 10 MINOR:0  BUILD: 14393
#Windows Server 2016 Fall Creators Update                            | MAJOR: 10 MINOR:0  BUILD: 16299
#Windows Server 2019 (Semi-Annual Channel) (Datacenter, Standard)    | MAJOR: 10 MINOR:0  BUILD: 17134
#Windows Server 2019                                                 | MAJOR: 10 MINOR:0  BUILD: 18342
#Windows Server 2019                                                 | MAJOR: 10 MINOR:0  BUILD: 17763
#Windows Server 2019                                                 | MAJOR: 10 MINOR:0  BUILD: 19041
#Windows Server 2019                                                 | MAJOR: 10 MINOR:0  BUILD: 19042
#Windows Server 2022 (preview)                                       | MAJOR: 10 MINOR:0  BUILD: 20285
#Windows Server 2022 (standard)                                      | MAJOR: 10 MINOR:0  BUILD: 20348