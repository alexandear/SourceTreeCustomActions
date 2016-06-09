#Reguires -Version 3.0

function Get-WebRequestStatusCode {
    param (
        [Parameter(Mandatory=$True)]
        [String]$Url
    )

    return Invoke-WebRequest $Url | % { $_.StatusCode }
}

function Check-UrlStatus {
    param (
        [Parameter(Mandatory=$True)]
        [String]$Url
    )

    try {
        $status = Get-WebRequestStatusCode $Url
    }
    catch [Net.WebException] {
        return $False
    }

    If ($status -eq 200) {
        return $True
    }
    return $False
}

function Get-GitConfigRemoteOriginUrl {
    param (
        [Parameter(Mandatory=$True)]
        [ValidateScript({ Test-Path $_ })]
        [String]$Repo
    )

    Push-Location $Repo
    $result = & git config remote.origin.url
    Pop-Location
    return $result
}

function Get-GitBranch {
    param (
        [Parameter(Mandatory=$True)]
        [ValidateScript({ Test-Path $_ })]
        [String]$Repo
    )

    Push-Location $Repo
    $branch = & git rev-parse --abbrev-ref HEAD
    Pop-Location
    return $branch
}

function Invoke-GitPush {
    param (
        [Parameter(Mandatory=$True)]
        [ValidateScript({ Test-Path $_ })]
        [String]$Repo,
        [Parameter(Mandatory=$True)]
        [String]$Branch,
        [Parameter(Mandatory=$False)]
        [AllowEmptyString()]
        [String]$ToCommit = "",
        [Parameter(Mandatory=$False)]
        [String]$Remote = "origin"
    )

    $to = $ToCommit
    if ([String]::IsNullOrWhitespace($ToCommit)) {
        $to = "HEAD"
    }

    Push-Location $Repo
    $params = "$ToCommit`:$Branch"
    & git push $Remote $params
    Pop-Location
}
