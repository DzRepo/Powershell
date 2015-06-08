# Powershell Utilities for working with the Gnip / Twitter Data API

_Historical Powertrack Scripts_

**CreateJob-Historical** - Creates new Historical Powertrack job

**GetJobs-Historical** - Retrieves status of existing jobs

**UpdateJob-Historical** - Accepts or rejects submitted jobs

**DownloadJob-Historical** - Downloads and optionally decompresses and concatanates the individual files into a single Json file

**DownloadJob-HistoricalCustomJob**  - Download and optionally decompresses and concatenates files from a custom HPT job

**Create-CombinedCsv** - Takes a combined file (from the download script) and creates a CSV file of specifc fields.

*Powertrack Stream Scripts*

**AddRule-PowerTrack** - Add new rule to existing Powertrack stream

**GetRules-PowerTrack** - download existing rules from Powertrack stream
#________________________________________________________________

*Common Parameters for all Scripts:*

**account** - Account name of GNIP account

**username** - username that's authorized to execute job

**password** - password that' authorized to execute job.  Note that to enable scripting, these scripts have left the password parameter as plaintext.

**title** - Unique name of Historical job

**streamname** - name of Powertrack stream (typically prod or dev)

All script parameters can be passed positionally or with parameter names.  For example:

`GetJobs-Historical *-account* "MyAccount" *-username* "myname@domain.com" *-password* "5up3r53cr3t!"`

is functionally the same as 

`GetJobs-Historical "MyAccount" "myname@domain.com" "5up3r53cr3t!"`

#=====================================================================================================

**CreateJob-Historical** - Creates new Historical Powertrack job

*Parameters:*

* **account** - see above
* **username** - see above
* **password** - see above
* **ruleFileName** - path to comma delimited text file with rules and tags.  ( See MyJobRules.txt for example. )
* **title** - see above
* **fromDate** - start date/time in UNC for search
* **toDate** - end date/time in UNC for search

*Returns*

* *string* - Status message returned by submission

#=====================================================================================================

**GetJobs-Historical** - Retrieves status of existing jobs

*Parameters:*

* **account** - see above
* **username** - see above
* **password** - see above
* **title** - see above
* **status** - *Optional* - Filter for a particular status type - defaults to "all'

*Returns:*

PowerShell array of 'JobStatus' objects, defined as

* *string*  **title** - name of job
* *string*   **status** - current status
* *string*   **statusMessage** - additional status message
* *integer*  **estimatedActivityCount** - estimated number of activities for new jobs 
* *integer*  **estimatedDurationHours** - estimated time to process for new jobs
* *integer*  **estimatedFileSizeMb** - estimated file size in MB for new jobs
* *integer*  **percentComplete** - percentage completed of running job
* *integer*  **activityCount** - number of activities found for completed job
* *integer*  **fileCount** - number of files for completed job
* *DateTime* **expiresAt** - date/time the files will be deleted

#=====================================================================================================

**UpdateJob-Historical** - Accepts or rejects submitted jobs

*Parameters:*

* **account** - see above
* **username** - see above
* **password** - see above
* **title** - see above
* **status** - either "accept" or "reject" to update status of job

*Returns:*

* **string** - Status message returned by submission

#=====================================================================================================

**DownloadJob-Historical** - Downloads and optionally decompresses and concatanates the individual files into a single Json file

*Parameters:*

* **account**  - see above
* **username** - see above
* **password** - see above
* **title**    - see above
* **clean**    - *Optional* ($true or $false) Remove individual .gz files after decompression
	* Defaults to $false
* **combine**  - *Optional* ($true or $false) create single file with activities in it, and remove individual .json files 
	* Defaults to $false

*Returns:*

* **string**   - Filename of either file list of downloaded files, or filename of combined files, depending on switch used.

#=====================================================================================================

**DownloadJob-HistoricalCustomJob** - Downloads and optionally decompresses and concatanates the individual files of a custom HPT job into a single Json file

*Parameters:*

* **account**  - see above
* **username** - see above
* **password** - see above
* **title**    - see above
* **clean**    - *Optional* ($true or $false) Remove individual .gz files after decompression
	- Defaults to *$false*
* **combine**  - *Optional* ($true or $false) creates single file with all activities in it, and remove individual .json files
	* Defaults to $false
* **startAt**  - start downloading at file#  (used to restart stalled jobs)

*Returns:*

* string   - Filename of either file list of downloaded files, or filename of combined files, depending on switch used.

#=====================================================================================================

**Create-CombinedCsv** - Takes a combined file (from the download script) and creates a CSV file of specifc fields.

*Parameters:*
		
* **filename** - name of combined file name created by Download script 
			   (enclose in quotes if there are spaces in the filename)

*Returns:*

By default, creates CSV file called "combined.csv"

**To change or add fields, open the script with a text editor and follow directions in file.**	
#=====================================================================================================
*PowerTrack Stream scripts*
#=====================================================================================================

**AddRule-Powertrack** - Adds new rule to Powertrack stream

*Parameters:*

* **account**  	- see above
* **username** 	- see above
* **password**  	- see above
* **streamname**  - see above
* **value**	    - rule value - "(cats OR dogs) -(puppies OR kittens)"
* **tag**  		- [Optional] - tag associated with rule

#=====================================================================================================

**GetRules-Powertrack** - Adds new rule to Powertrack stream

*Parameters:*

* **account**  	- see above
* **username** 	- see above
* **password**  	- see above
* **streamname**  - see above
		
*Returns*

A JSON formatted list of current rules.  Can be modified to return pure PowerShell
	objects by removing/commenting out "convertto-json" formatting in script.
#=====================================================================================================
