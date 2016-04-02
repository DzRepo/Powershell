[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$account,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$username,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$password,

    [Parameter(Mandatory=$True, Position=4)]
    [string]$label,

    [Parameter(Mandatory=$True, Position=5)]
    [string]$query,

    [Parameter(Mandatory=$True, Position=6)]
    [string]$querytype,

    [Parameter(Position=7)]
    [int]$maxRecords = -1,
    
    [Parameter(Position=8)]
    [string]$fromDate=$null,
    
    [Parameter(Position=9)]
    [string]$toDate=$null
)

$DebugPreference=$VerbosePreference="SilentlyContinue"
$maxResults = 500


$allResults = @()

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")        
$jsonserial= New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer 
$jsonserial.MaxJsonLength  = 401520970

$dir = pwd
Write-Host

$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

if ($querytype.ToLower() -eq "data")
{
    $url = "https://data-api.twitter.com/search/fullarchive/accounts/" + $account + "/" + $label + ".json"
}
else
{
    $url = "https://data-api.twitter.com/search/fullarchive/accounts/" + $account + "/" + $label + "/counts.json"
}

$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

if ($querytype.ToLower() -eq "data")
{
    $body = @{ query = $query; maxResults = $maxResults }

    if ($fromDate.Length -ne 0) { $body["fromDate"] = $fromDate}
    if ($toDate.Length -ne 0) { $body["toDate"] = $toDate}
}
else
{
    $body = @{ query = $query }
    if ($fromDate.Length -ne 0) { $body["fromDate"] = $fromDate}
    if ($toDate.Length -ne 0) { $body["toDate"] = $toDate}
}   

# $returnValue = ""
$TotalRecords = 0
try
{
    $Stop = $false
	$ProgressPreference=’SilentlyContinue’

    while (-not $Stop)
    {
	    $resultRaw = Invoke-RestMethod -Uri $url -Method POST -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -ContentType "application/json" -Body (ConvertTo-Json $body)
	    $ProgressPreference='Continue’
	    $Result = $resultRaw
        foreach($resultRow in $Result.results)
        {
            $TotalRecords += 1
            $allResults += $resultRow 
  
            if (($TotalRecords -ge $maxRecords) -and ($maxRecords -gt 0)) {
                $Stop = $True
                break 
            }       
        }
        if ($Result.next -eq $null)
        {
            $Stop = $True
        }
        else
        {
            $body = @{ query = $query; maxResults = $maxResults; next = $Result.next }
            if ($fromDate.Length -ne 0) { $body["fromDate"] = $fromDate}
            if ($toDate.Length -ne 0) { $body["toDate"] = $toDate}
        }
    }

    write-host "Total Records:" $TotalRecords
    $resultObject = @{ results = $allResults }
    Write-Output $resultObject | ConvertTo-Json -Compress -Depth 99
}
catch [System.Net.WebException],[System.Exception]
{
	write-host "Error retrieving information: " $_
}
