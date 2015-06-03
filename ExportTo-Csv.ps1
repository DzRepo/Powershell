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

$bytesRead = 0

$reader = [System.IO.File]::OpenText($ActivityFilePath)
$writer = [System.IO.File]::CreateText($CSVFilePath)
for(;;) {
    $line = $reader.ReadLine()
    if ($line -eq $null) { break }
    # process the line
    $bytesRead += $line.Length
    $obj = ConvertFrom-Json $line
    $writer.WriteLine($obj.actor.preferredUsername)
    Write-Progress -Activity "Exporting to CSV" -status $bytesRead -percentComplete ($bytesRead / $ActivityFileSize) -Id 1
}
$writer.Close();
$reader.Close()
