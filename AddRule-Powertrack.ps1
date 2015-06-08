[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$account,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$username,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$password,

    [Parameter(Mandatory=$True, Position=4)]
    [string]$streamname,

    [Parameter(Mandatory=$True, Position=5)]
    [string]$value,

    [Parameter(Mandatory=$False, Position=6)]
    [string]$tag
 )


Add-Type -Language CSharp @"
public class rule{
	public string value;
	public string tag;
}
public class rulesArray{
	public rule[] rules;
}
"@;

$ruleArray=@()

$newRules = new-object rulesArray
$newRule = new-object rule
$newRule.value = $value
$newRule.tag = $tag

$newRules.rules += $newRule


$JsonBody = $newRules | ConvertTo-json
$jsonBody

$url = "https://api.gnip.com:443/accounts/" + $account + "/publishers/twitter/streams/track/" + $streamname + "/rules.json"

$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)


try
{
	$Result = Invoke-RestMethod -Uri $url -Method POST -Credential $cred -ContentType "application/json" -Body $JsonBody
	$Result
}
catch [System.Net.WebException],[System.Exception]
{
	write-host "Error adding rule: " $_.Message
}



