# SourceTree Custom Actions

## Actions

Scripts directory contains following custom actions:

* View repo on GitLab
* View commit on GitLab
* View file commit on GitLab
* View file on GitLab
* Push commits to here

## Installation

### Prerequisites

* SourceTree for Windows
* PowerShell 3.0 and higher

### SourceTree Setup

Clone files from `Scripts` directory to some folder, e.g. `C:\SourceTreeCustomActions`.

Go into `Tools` > `Options` and add new custom actions:

Menu caption | Parameters
--------------------|-------------
View repo on GitLab | `-NonInteractive -ExecutionPolicy ByPass -File C:\SourceTreeCustomActions\ViewThingsOnGitLab.ps1 -Repo $REPO -SHA $SHA -File $FILE -ViewRepo`
View commit on GitLab | `-NonInteractive -ExecutionPolicy ByPass -File C:\SourceTreeCustomActions\ViewThingsOnGitLab.ps1 -Repo $REPO -SHA $SHA -File $FILE -ViewCommit`
View file on GitLab | `-NonInteractive -ExecutionPolicy ByPass -File C:\SourceTreeCustomActions\ViewThingsOnGitLab.ps1 -Repo $REPO -SHA $SHA -File $FILE -ViewFile`
View file commit on GitLab | `-NonInteractive -ExecutionPolicy ByPass -File C:\SourceTreeCustomActions\ViewThingsOnGitLab.ps1 -Repo $REPO -SHA $SHA -File $FILE -ViewFileCommit`
Push to here | `-NonInteractive -ExecutionPolicy ByPass -File C:\SourceTreeCustomActions\PushToHere.ps1 -Repo $REPO -SHA $SHA`

## Tests

Tests are run using [Pester](https://github.com/pester/Pester).

## Credits

The project was inspired by [SourceTree for Windows and GitHub](https://github.com/damieng/DamienGKit/tree/master/Powershell/SourceTree).
