CreateJob-Historical - Creates new Historical Powertrack job
GetJobs-Historical - Retrieves status of existing jobs
UpdateJob-Historical - Accepts or rejects submitted jobs
DownloadJob-Historical - Downloads and optionally decompresses and concatanates the individual files into a single Json file

Common Parameters for all Scripts:

account - Account name of GNIP account
username - username that's authorized to execute job
password - password that' authorized to execute job.  Note that to enable scripting, these scripts have left the password parameter as plaintext.
title - Unique name of Historical job

All script parameters can be passed positionally or with parameter names.  For example:

GetJobs-Historical -account "MyAccount" -username "myname@domain.com" -password "5up3r53cr3t!"

is functionally the same as 

GetJobs-Historical "MyAccount" "myname@domain.com" "5up3r53cr3t!"


CreateJob-Historical - Creates new Historical Powertrack job
	Parameters:
		account - see above
		username - see above
		password - see above
		ruleFileName - path to comma delimited text file with rules and tags.  See MyJobRules.txt for example.
		title - see above
		fromDate - start date/time in UNC for search
		toDate - end date/time in UNC for search
	Returns
		string - Status message returned by submission


GetJobs-Historical - Retrieves status of existing jobs
	Parameters:
		account - see above
		username - see above
		password - see above
		title - see above
		status - [Optional] filter for a particular status type - defaults to "all'
	Returns
		PowerShell array of 'JobStatus' objects, defined as 
			string   title - name of job
			string   status - current status
			string   statusMessage - additional status message
			integer  estimatedActivityCount - estimated number of activities for new jobs 
			integer  estimatedDurationHours - estimated time to process for new jobs
			integer  estimatedFileSizeMb - estimated file size in MB for new jobs
			integer  percentComplete - percentage completed of running job
			integer  activityCount - number of activities found for completed job
			integer  fileCount - number of files for completed job
			DateTime expiresAt - date/time the files will be deleted


UpdateJob-Historical