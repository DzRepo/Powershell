[CmdletBinding()] 
param (
    [Parameter(Mandatory=$True, Position=1)]
    [string]$account,

    [Parameter(Mandatory=$True, Position=2)]
    [string]$username,

    [Parameter(Mandatory=$True, Position=3)]
    [string]$password,

    [Parameter(Mandatory=$True, Position=4)]
    [string]$streamname
 )


$url = "https://stream.gnip.com:443/accounts/" + $account + "/publishers/twitter/streams/track/" + $streamname + ".json"

# // create a request
try
{

	[Net.HttpWebRequest] $req = [Net.WebRequest]::create($url)
	$req.Method = "GET"
	$req.Timeout = 600000 # = 10 minutes

	# // Set if you need a username/password to access the resource
	$req.Credentials = New-Object Net.NetworkCredential($username, $password);
	$req.AutomaticDecompression = 2 -bor 3
	[Net.HttpWebResponse] $request = $req.GetResponse()
	[IO.Stream] $stream = $request.GetResponseStream()
	[IO.StreamReader] $reader = New-Object IO.StreamReader($stream)
	$outputInit = " " * 4096
	$output = $outputInit.ToCharArray()
	do {
		$outputLength = $reader.ReadBlock($output, 0, 4096)
		# Need to convert from UTF-8 to text.
		write-host  $output -nonewline
	}
	while (! [string]::IsNullOrEmpty($output))

	$stream.flush()
	$stream.close()

}
catch [System.Net.WebException],[System.Exception]
{
	write-host "Error opening stream: " $_.
}
