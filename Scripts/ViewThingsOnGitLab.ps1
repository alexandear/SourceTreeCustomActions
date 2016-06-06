param (
    [Parameter(Mandatory=$True)]
    [ValidateScript({ Test-Path $_ })]
    [String]$Repo,
    [Parameter(Mandatory=$True)]
    [String]$SHA,
    [Parameter(Mandatory=$True)]
    [String]$File,
    [Parameter(Mandatory=$False)]
    [Switch]$ViewRepo,
    [Parameter(Mandatory=$False)]
    [Switch]$ViewCommit,
    [Parameter(Mandatory=$False)]
    [Switch]$ViewFileCommit,
    [Parameter(Mandatory=$False)]
    [Switch]$ViewFile
)

. "$PSScriptRoot\GitLabUrls.ps1"

try {
    $url = Get-UrlViewThingsOnGitLab -Repo $Repo -SHA $SHA -File $File -ViewRepo:$ViewRepo -ViewCommit:$ViewCommit `
                                     -ViewFileCommit:$ViewFileCommit -ViewFile:$ViewFile
    Start-Process $url
} catch {
    $_.Exception.Message
    exit 1
}

