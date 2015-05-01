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

    [Parameter(Position=5)]
    [bool]$clean=$false,
    
    [Parameter(Position=6)]
    [bool]$combine=$false
 )

. "./gzip.ps1"


[void][System.Reflection.Assembly]::LoadWithPartialName("System.Web.Extensions")        
$jsonserial= New-Object -TypeName System.Web.Script.Serialization.JavaScriptSerializer 
$jsonserial.MaxJsonLength  = 201520970

$dir = pwd

$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

$url = "https://historical.gnip.com:443/accounts/" + $account + "/jobs.json"
$secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($username, $secpasswd)

$returnValue = ""
try
{
	$ProgressPreference=’SilentlyContinue’
	$resultRaw = Invoke-RestMethod -Uri $url -Method Get -Credential $cred -ContentType "application/json"
	$ProgressPreference='Continue’
	$Result = $resultRaw
	Write-host "Job found: " $Result.jobs[0].title
	

	foreach ($obj in $Result){ 
		foreach ($job in $obj.Jobs)
		{
			if ($job.title -eq $title) 		
			{
				write-verbose "Title: $job.title"

				$jobURL = $job.jobURL

				if ($job.status -eq "delivered")
				{
					
					try
					{
						$ProgressPreference=’SilentlyContinue’	
						$JobResult = Invoke-RestMethod -Uri $jobURL -Method Get -Credential $cred -ContentType "application/json"
						$ProgressPreference='Continue’

						$JobResultsDetail = $JobResult.results

						write-host "Number of Activities: "  $JobResultsDetail.activityCount
						write-host "Number of Files: " $JobResultsDetail.fileCount

						$ProgressPreference=’SilentlyContinue’
						$fileList = Invoke-RestMethod -Uri $jobResultsDetail.dataURL -Method Get -Credential $cred -ContentType "application/json"
						$ProgressPreference='Continue’
												
						$DecompressedFileName = $dir.path + "\" + $job.title + "-files.txt"
						$returnValue = $DecompressedFileName

						#make sure to start with a blank file
						#Delete filelist file if it exists, suppress error if it doesn't
						Remove-Item $DecompressedFileName -ErrorAction SilentlyContinue 
						Add-Content $DecompressedFileName  "Filename"
						
						$fileNumber = 0
	 					foreach ($file in $fileList.urlList)
	 					{
							$fileNumber++
							$fileNumberString = "000000" + $fileNumber 
							$fileNumberString = $fileNumberString.Substring($fileNumberString.Length-6,6)
							$destFile = $title + "-file" + $fileNumberString + ".json.gz"
							Write-Progress -Activity "Downloading files" -status $destFile -percentComplete ($fileNumber / $JobResultsDetail.fileCount*100) -Id 1
							$ProgressPreference=’SilentlyContinue’
							Invoke-WebRequest $file -OutFile $destFile
							$ProgressPreference='Continue’
						 }
						Write-Progress -Activity "Downloading files" -Completed -Id 1

		
						$fileNumber = 0
						foreach ($file in $fileList.urlList)
						{
							$fileNumber++
							$fileNumberString = "000000" + $fileNumber 
							$fileNumberString = $fileNumberString.Substring($fileNumberString.Length-6,6)
							$destFile = $dir.path + "\" +  $title + "-file" + $fileNumberString + ".json"
							$sourceFile = $destFile + ".gz"
							Write-Progress -Activity "Decompressing files" -status $destFile -percentComplete ($fileNumber / $JobResultsDetail.fileCount*100) -Id 1
							DeGzip-File $sourceFile $destFile
							$LogFileName = '"' + $destFile + '"'
							Add-Content  $DecompressedFileName $LogFileName
							
							if ($clean) { remove-item $sourceFile }
						}
						Write-Progress -Activity "Decompressing files" -Completed -Id 1

						if ($combine)
						{
							$CombinedFileName = $dir.path + "\" + $job.title + "-combined.json"
							$returnValue = $CombinedFileName
							
							$lineIndex = 0
							$fileNumber = 0

							$JsonFileList = Import-Csv $DecompressedFileName;
							foreach ($fileToClean in $JsonFileList)
							{
								$fileNumber++
								$fileToRead = $fileToClean.Filename
								$fileContents = Get-Content -Path $fileToRead
						
								Write-Progress -Activity "Combining - Processing file" -status $fileToRead -percentComplete ($fileNumber / $JobResultsDetail.fileCount*100) -Id 1
								foreach ($textLine in $fileContents)
								{
									if (($textLine.Length -gt 0)  -and ($textLine.StartsWith('{"id":')))
									{
										$lineIndex++
										Write-Progress -Activity "Processing Activities" -status "Activity $lineIndex" -percentComplete ($lineIndex / $JobResultsDetail.activityCount*100) -Id 2 -ParentId 1
										Add-Content $CombinedFileName $textLine
									}
								}
								Remove-Item $fileToRead
							}

						}
					$returnValue
					}
					catch [System.Net.WebException],[System.Exception]
					{
						write-host "Error downloading job: " $_
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
	
