[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$account,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$username,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$password,

    [Parameter(Mandatory=$True, Position=4)]
    [string]$ruleFileName,

    [Parameter(Mandatory=$True, Position=5)]
    [string]$title,

    [Parameter(Mandatory=$True, Position=6)]
    [string]$fromDate,

    [Parameter(Mandatory=$True, Position=7)]
    [string]$toDate
 )

$RuleObjects = Import-Csv $ruleFileName;

Add-Type -Language CSharp @"
public class GRule{
	public string value;
	public string tag;
	}

public class HPTRequest{
	public string publisher;
	public string streamType;
	public string dataFormat;
	public string fromDate;
	public string toDate;
	public string title;
	public GRule[] rules;
}
"@;


$MyRequest = new-object HPTRequest;
$MyRequest.publisher = "twitter";
$MyRequest.streamType = "track";
$MyRequest.dataFormat = "activity-streams";

$MyRequest.title = $title;
$MyRequest.fromDate = $fromDate;
$MyRequest.toDate = $toDate;

$MyRequest.rules = @();

foreach ($newRule in $RuleObjects)
{
	$MyRule = new-object GRule;
	$MyRule.value = $newRule.Value;
	$MyRule.tag = $newRule.Tag;
	$MyRequest.rules += $MyRule;
}

$MyJsonRequest = $MyRequest | ConvertTo-Json

$url = "https://historical.gnip.com:443/accounts/" + $account + "/jobs.json"

write-host "Submitting job to " $url

$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

try
{
	$response = Invoke-RestMethod -Uri $url -Method Post -Credential $cred -ContentType "application/json" -Body $MyJsonRequest

}
catch [System.Net.WebException],[System.Exception]
{
	write-host "Error submitting job: " $_
}

$response.statusMessage
