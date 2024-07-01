# Local Group Members Enumeration Script

This PowerShell script enumerates the members of local groups on a Windows machine using ADSI (Active Directory Service Interfaces). It reads a list of local groups from a file, retrieves the members of each group, prints the results to the console, and saves them to an output file.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Script Details](#script-details)
- [Error Handling](#error-handling)
- [Sample Output](#sample-output)

## Prerequisites

- Windows operating system
- PowerShell (version 5.1 or later)
- Appropriate permissions to query local group memberships

## Usage

1. Save the following script to a `.ps1` file, e.g., `EnumerateLocalGroupMembers.ps1`.

2. Open PowerShell with administrative privileges.

3. Run the script:

    ```powershell
    .\EnumerateLocalGroupMembers.ps1
    ```

## Script Details

### Step 1: Define File Paths

Define the paths for the input and output text files. The input file will contain the list of local groups, and the output file will store the results.

```powershell
$inputFilePath = "$env:USERPROFILE\Desktop\LocalGroups.txt"
$outputFilePath = "$env:USERPROFILE\Desktop\LocalGroupsMembers.txt"
```

### Step 2: Retrieve Local Groups

Retrieve the list of local groups and save it to the input file.

```powershell
Get-LocalGroup | Select-Object Name | Out-File -FilePath $inputFilePath
```

### Step 3: Read Input File

Read the content of the input file into an array and skip the header lines.

```powershell
$fileContent = Get-Content -Path $inputFilePath
$groups = $fileContent[2..$fileContent.Length]
```

### Step 4: Initialize Output Array

Initialize an array to hold the results.

```powershell
$output = @()
```

### Step 5: Iterate Over Groups and Enumerate Members

Iterate over each group name, trim whitespace, and check if the line is not empty. Bind to the local group using ADSI, enumerate the members, and handle any errors.

```powershell
foreach ($group in $groups) {
    $groupName = $group.Trim()
    
    if ($groupName -ne "") {
        $output += "Members of group: $groupName"
        Write-Output "Members of group: $groupName"

        try {
            $adsiGroup = [ADSI]"WinNT://./$groupName,group"
            
            foreach ($member in $adsiGroup.Members()) {
                $memberName = $member.GetType().InvokeMember("Name", 'GetProperty', $null, $member, $null)
                $output += " - $memberName"
                Write-Output " - $memberName"
            }
        } catch {
            $output += "Error retrieving members for group: $groupName"
            Write-Output "Error retrieving members for group: $groupName"
        }
    }
}
```

### Step 6: Save Output

Save the results to the output file.

```powershell
$output | Out-File -FilePath $outputFilePath
```

## Error Handling

The script includes a `try` block to attempt to retrieve group members and a `catch` block to handle any errors, such as if the group does not exist.

## Sample Output

The output file will contain the list of group members for each group, formatted as follows:

```
Members of group: Administrators
 - Administrator
 - User1
Members of group: Remote Desktop Users
 - User2
Error retrieving members for group: NonExistentGroup
