[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$filename
 )


$fileContents = Get-Content $filename

# To change or add fields, first change this class declaration:
# notice the format is "public type name;"

Add-Type -Language CSharp @"
public class NewActivity{
	public string id;
	public string displayName;
	public string link;
	public string body;
	public string twitter_lang;
	public System.DateTime postedTime;
}
"@;


$allrows=@()

$rowNumber = 0
	 					
foreach ($row in $fileContents)
{
	$rowNumber++
	Write-Progress -Activity "Exporting Records to Combined.csv" -status $rowNumber -percentComplete ($rowNumber / $fileContents.length*100) -Id 1
	$obj = $row | ConvertFrom-Json 	
	$newActivity = new-object NewActivity

# To add or change fields, next edit or add rows below to copy data from $obj to $newActivity fields defined above.
# Notice how the actor sub-object is referenced (for displayName).
# See http://support.gnip.com/sources/twitter/data_format.html#TweetActivities for full definition of activity object

	$newActivity.id = $obj.id 
	$newActivity.displayName = $obj.actor.displayName
	$newActivity.link = $obj.link
	$newActivity.body = $obj.body
	$newActivity.twitter_lang = $obj.twitter_lang
	$newActivity.postedTime = $obj.postedTime
	$allrows += $newActivity
}

$allrows | Export-Csv "combined.csv"