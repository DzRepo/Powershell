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

	$index = 0

	$writer.WriteLine( "id,body,language,postTime,shape,p1,p2,p3,p4")

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
    	
    		Write-Progress -Activity "Export to CSV" -status ('Row:' + $index) -percentComplete (($bytesRead / $ActivityFileSize) * 100) -Id 1

		$geoText = ""
		$body = $obj.body.Replace($quote, $quote + $quote)

                if ($location.geo.type -eq "point")
		{
			$geoText = $geo[0][0] 
		}
		if ($location.geo.type -eq "polygon")
		{
			$geoText = $geo[0][0] + $comma +
			$geo[0][1] + $comma +
			$geo[0][2] + $comma +
			$geo[0][3] 
		}
    
    		$writer.WriteLine(
			$quote + $obj.id + $quote  + $comma +
			$quote + $body + $quote + $comma + 
			$quote + $obj.twitter_lang + $quote + $comma + 
			$obj.postedTime + $comma + 
			$quote + $location.geo.type + $quote + $comma +
			$geoText
		)

		$index +=1

		# used for testing
		# if ( $index -gt 100 ) { break }
	}

}
catch [System.Net.WebException],[System.Exception]
{
	$ex = $_
	write-host -foregroundcolor Red "Error exporting to CSV: " -nonewline
	write-host -foregroundcolor Yellow $_
	write-host -foregroundcolor Red "Script line number:" -nonewline
	write-host -foregroundcolor Yellow $ex.InvocationInfo.ScriptLineNumber
	write-host -foregroundcolor Yellow "Processsing row:" -nonewline
	write-host -foregroundcolor White $index -nonewline
}
try
{
	$writer.Close();
	$reader.Close()
}
catch [System.Exception]
{}
