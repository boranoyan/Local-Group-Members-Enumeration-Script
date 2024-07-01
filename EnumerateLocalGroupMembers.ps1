# Path to the input and output text files
$inputFilePath = "$env:USERPROFILE\Desktop\LocalGroups.txt"
$outputFilePath = "$env:USERPROFILE\Desktop\LocalGroupsMembers.txt"

# Get local groups and save to the input file
Get-LocalGroup | Select-Object Name | Out-File -FilePath $inputFilePath

# Read the content of the input file
$fileContent = Get-Content -Path $inputFilePath

# Skip the header lines (first two lines)
$groups = $fileContent[2..$fileContent.Length]

# Initialize an array to hold the output
$output = @()

# Get the hostname of the local machine
$hostname = $env:COMPUTERNAME

# Iterate over each group and run ADSI to enumerate group members
foreach ($group in $groups) {
    # Trim any leading/trailing whitespace from the group name
    $groupName = $group.Trim()
    
    # Check if the line is not empty
    if ($groupName -ne "") {
        # Add the group name with hostname to the output array and print it to the screen
        $output += "Members of group '$groupName' on host '$hostname':"
        Write-Output "Members of group '$groupName' on host '$hostname':"

        try {
            # Use ADSI to bind to the local group
            $adsiGroup = [ADSI]"WinNT://./$groupName,group"

            # Enumerate group members
            foreach ($member in $adsiGroup.Members()) {
                # Retrieve the member name
                $memberName = $member.GetType().InvokeMember("Name", 'GetProperty', $null, $member, $null)
                # Add the member name to the output array and print it to the screen
                $output += " - $memberName"
                Write-Output " - $memberName"
            }
        } catch {
            # If an error occurs, add the error message to the output array and print it to the screen
            $output += "Error retrieving members for group: $groupName"
            Write-Output "Error retrieving members for group: $groupName"
        }
    }
}

# Save the output to the output file
$output | Out-File -FilePath $outputFilePath
