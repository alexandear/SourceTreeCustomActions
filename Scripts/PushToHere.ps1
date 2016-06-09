param (
    [Parameter(Mandatory=$True)]
    [ValidateScript({ Test-Path $_ })]
    [String]$Repo,
    [Parameter(Mandatory=$True)]
    [String]$SHA
)

. "$PSScriptRoot\Common.ps1"

$currentBranch = Get-GitBranch -Repo $Repo
Invoke-GitPush -Repo $Repo -Branch $currentBranch -ToCommit $SHA
