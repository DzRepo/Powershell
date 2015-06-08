[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$username,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$password,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$JobURL,

    [Parameter(Position=4)]
    [bool]$clean=$false,
    
    [Parameter(Position=5)]
    [bool]$combine=$false,

    [Parameter(Position=6)]
    [int]$StartAt=0
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
$title = "CustomHPTJob"
try
{
	Write-Host "Getting File List"
	$fileListRaw = Invoke-RestMethod -Uri $jobURL -Method Get -Credential $cred -ContentType "application/json"
	Write-Host "Finished getting File List"

	#1 ) Uncomment out the line below to use JavaScript Deserializer
	$fileList = $jsonserial.DeserializeObject($fileListRaw)

	# 
	# $fileListJson = ConvertTo-Json $fileListRaw
	# $fileListJson.expiresAt
	
	
	# 2) comment the line below to use JavaScript deserializer.
	# $fileList = $fileListRaw

	$fileCount = $fileList.urlList.Count
	$DecompressedFileName = $dir.path + "\" + $title + "-files.txt"
	
	$returnValue = $DecompressedFileName

	#make sure to start with a blank file
	#Delete filelist file if it exists, suppress error if it doesn't
	Remove-Item $DecompressedFileName -ErrorAction SilentlyContinue 
	Add-Content $DecompressedFileName  "Filename"
						
	$fileNumber = 0
	
	Write-Host "Number of files" $fileCount

	foreach ($file in $fileList.urlList)
	{
		$fileNumber++
		# handle skipping files already downloaded.
		if ($fileNumber -ge $startAt) 
		{
			$fileNumberString = "000000" + $fileNumber 
			$fileNumberString = $fileNumberString.Substring($fileNumberString.Length-6,6)
			$destFile = $title + "-file" + $fileNumberString + ".json.gz"
			Write-Progress -Activity "Downloading files" -status $destFile -percentComplete ($fileNumber / $fileCount*100) -Id 1
			$ProgressPreference=’SilentlyContinue’
			Invoke-WebRequest $file -OutFile $destFile
			$ProgressPreference='Continue’
		}
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
		Write-Progress -Activity "Decompressing files" -status $destFile -percentComplete ($fileNumber / $fileCount*100) -Id 1
		DeGzip-File $sourceFile $destFile
		$LogFileName = $destFile
		Add-Content $DecompressedFileName  $LogFileName
							
		if ($clean) { remove-item $sourceFile }
	}
	Write-Progress -Activity "Decompressing files" -Completed -Id 1

	if ($combine)
	{
		$CombinedFileName = $dir.path + "\" + $title + "-combined.json"
		$returnValue = $CombinedFileName

		$lineIndex = 0
		$fileNumber = 0

		$JsonFileList = Import-Csv $DecompressedFileName;
		foreach ($fileToClean in $JsonFileList)
		{
			$fileNumber++
			$fileToRead = $fileToClean.Filename
			$fileContents = Get-Content -Path $fileToRead
						
			Write-Progress -Activity "Combining - Processing file" -status $fileToRead -percentComplete ($fileNumber / $fileCount*100) -Id 1
			foreach ($textLine in $fileContents)
			{
				if (($textLine.Length -gt 0)  -and ($textLine.StartsWith('{"id":')))
				{
					$lineIndex++
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
