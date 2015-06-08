[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$account,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$username,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$password,

    [Parameter(Mandatory=$True, Position=4)]
    [string]$streamname
 )

$dir = pwd

$LabelColor = "Yellow"
$OutputColor = "Green"

$url = "https://api.gnip.com:443/accounts/" + $account + "/publishers/twitter/streams/track/" + $streamname + "/rules.json"

$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)


try
{
	$Result = Invoke-RestMethod -Uri $url -Method Get -Credential $cred -ContentType "application/json"
	$Result | ConvertTo-Json
}
catch [System.Net.WebException],[System.Exception]
{
	write-host "Error retrieving rules: " $_.Message
}



