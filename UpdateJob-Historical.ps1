[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$account,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$username,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$password,

    [Parameter(Mandatory=$True, Position=4)]
    [string]$title,

    [ValidateSet('accept','reject', ignorecase=$True)]
    [Parameter(Mandatory=$True, Position=5)]
    [string]$status
 )

$Accept = '{"status":"accept"}'
$Reject = '{"status":"reject"}'

if ($status.ToLower() -eq "accept") { $JsonBody = $Accept }
elseif ($status.ToLower() -eq "reject") { $JsonBody = $reject }

$dir = pwd

$LabelColor = "Yellow"
$OutputColor = "Green"


$url = "https://historical.gnip.com:443/accounts/" + $account + "/jobs.json"
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)


try
{
	$result = Invoke-RestMethod -Uri $url -Method Get -Credential $cred -ContentType "application/json"

	foreach ($obj in $Result){ 
		foreach ($job in $obj.Jobs)
		{
			
			if ($job.title -eq $title) 
			{

				$jobURL = $job.jobURL

				if ($job.status -eq "quoted")
				{
					
					try
					{

						$JobResult = Invoke-RestMethod -Uri $jobURL -Method Get -Credential $cred -ContentType "application/json"
						write-host "Status Message: " -foreground $LabelColor -NoNewLine
						write-host $jobResult.statusMessage
						
						$url = $JobResult.jobURL;
											
						$response = Invoke-RestMethod -Uri $url -Method Put -Credential $cred -ContentType "application/json" -Body $JsonBody
						$response.statusMessage
					}
					catch [System.Net.WebException],[System.Exception]
					{
						write-host "Error updating job: " $_
					}
						
				}
			}
		}

	}
}
catch [System.Net.WebException],[System.Exception]
{
	write-host "Error retrieving job information: " $_
}



