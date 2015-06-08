[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$account,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$username,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$password,

    [string]$status="all"
)

$dir = pwd

$LabelColor = "Yellow"
$OutputColor = "Green"


$url = "https://historical.gnip.com:443/accounts/" + $account + "/jobs.json"

# Convert plain text password to secure password and create credentials.
#  To password mask the password field, change [string] to [Security.SecureString] and  
#  replace $secpasswd in the PSCredential call below with $password).
#
#  Note that this change will remove the ability to pass the password into the script from the command line.
#
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)


Add-Type -Language CSharp @"
public class JobStatus{
	public string title;
	public string status;
	public string statusMessage;
	public int estimatedActivityCount;
	public int estimatedDurationHours;
	public int estimatedFileSizeMb;
	public int percentComplete;
	public int activityCount;
	public int fileCount;
	public System.DateTime expiresAt;
}
"@;


#Create Results Array
$Results = @();

try
{
	$result = Invoke-RestMethod -Uri $url -Method Get -Credential $cred -ContentType "application/json"

	
	foreach ($obj in $Result){ 
		foreach ($job in $obj.Jobs)
		{
			
			
			if (($job.status -eq $status) -or ($status -eq "all"))
			{
				$JobInfo = new-object JobStatus;
				$JobInfo.title = $job.title
				$JobInfo.status = $job.status
				$JobInfo.statusMessage = $JobResult.statusMessage
				$jobURL = $job.jobURL

				if ($job.status -eq "quoted")
				{
 					$JobResult = Invoke-RestMethod -Uri $jobURL -Method Get -Credential $cred -ContentType "application/json"
					$JobInfo.expiresAt =  $JobResult.quote.expiresAt;
					$JobInfo.estimatedActivityCount = $JobResult.quote.estimatedActivityCount
					$JobInfo.estimatedFileSizeMb = $JobResult.quote.estimatedFileSizeMb
					$JobInfo.estimatedDurationHours = $JobResult.quote.estimatedDurationHours
						
				}
				elseif ($job.status -eq "running")
				{
					$JobResult = Invoke-RestMethod -Uri $jobURL -Method Get -Credential $cred -ContentType "application/json"
					$JobInfo.percentComplete = $JobResult.percentComplete
					$JobInfo.status = $JobResult.status
					$JobInfo.statusMessage = $JobResult.statusMessage

				}
				elseif ($job.status -eq "delivered")
				{
					
					$JobResult = Invoke-RestMethod -Uri $jobURL -Method Get -Credential $cred -ContentType "application/json"
					$JobResultsDetail = $JobResult.results
					$JobInfo.activityCount = $JobResultsDetail.activityCount
					$JobInfo.fileCount = $JobResultsDetail.fileCount
					$JobInfo.expiresAt = $JobResultsDetail.expiresAt

				}
				$Results += $JobInfo;
			}
			
		}

	}
}
catch [System.Net.WebException],[System.Exception]
{
	write-host "Error retrieving job information: " $_
}
$Results