[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$ActivityFile,
    [Parameter(Mandatory=$True, Position=2)]
    [string]$CSVFile
 )

$ActivityFilePath = $PSScriptRoot + "\" + $ActivityFile
$CSVFilePath = $PSScriptRoot + "\" + $CSVFile

$fileInfo = Get-Item $ActivityFilePath
$ActivityFileSize = $fileInfo.length

$quote =  """"
$comma = ","

$bytesRead = 0


try
{
	# Add references for HttpUtility
	Add-Type -AssemblyName  System.Web

	$reader = [System.IO.File]::OpenText($ActivityFilePath)
	$writer = [System.IO.File]::CreateText($CSVFilePath)
	$Encode = [System.Web.HttpUtility]::UrlEncode($URL) 

	 # $index = 0

	for(;;) {
	    	$line = $reader.ReadLine()
   	 	if ($line -eq $null) { break }
 	   	
		# process the line
 	   	$bytesRead += $line.Length
 	   	$obj = ConvertFrom-Json $line
    
 	   	# create a blank polygon array to eliminate nulls
 	   	$geo = @("","","","","","","","","","")
	
    		$location = $obj.location
    		
		if ($location -ne $null) {
			$geo = $location.geo.coordinates
    		}
    	
    		Write-Progress -Activity "Export to CSV" -status $bytesRead -percentComplete ($bytesRead / $ActivityFileSize) -Id 1
    
    		$writer.WriteLine(
			$quote + $obj.id + $quote  + $comma +
			$quote + $obj.body + $quote + $comma + 
			$quote + $obj.twitter_lang + $quote + $comma + 
			$obj.postedTime + $comma + 
			$quote + $location.geo.type + $quote + $comma +
			$geo[0][0] + $comma +
			$geo[0][1] + $comma +
			$geo[0][2] + $comma +
			$geo[0][3] + $comma +
			$geo[0][4] + $comma +
			$geo[0][5] + $comma +
			$geo[0][6] + $comma +
			$geo[0][7] 
		)

		# $index +=1
		# if ( $index -gt 100 ) { break }
	}

}
catch [System.Net.WebException],[System.Exception]
{
	$ex = $_
	write-host -foregroundcolor Red "Error exporting to CSV: " -nonewline
	write-host -foregroundcolor Yellow $_
	write-host -foregroundcolor Red "Line number:" -nonewline
	write-host -foregroundcolor Yellow $ex.InvocationInfo.ScriptLineNumber
}
try
{
	$writer.Close();
	$reader.Close()
}
catch [System.Exception]
{}
