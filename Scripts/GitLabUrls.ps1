. "$PSScriptRoot\Common.ps1"

function Get-GitLabUrlFromGitSsh {
    param (
        [Parameter(Mandatory=$True)]
        [String]$OriginUrl
    )

    $partsUrl = $OriginUrl.replace("git@", "").replace(".git", "").split(":")
    $urlPath = $partsUrl -join("/")

    $remoteHttpUrl = "http://" + $urlPath
    if (Test-UrlExist $remoteHttpUrl) {
        return $remoteHttpUrl
    }

    $remoteHttpsUrl = "https://" + $urlPath
    if (Test-UrlExist $remoteHttpsUrl) {
        return $remoteHttpsUrl
    }

    throw "Could not find GitLab url for remote: $OriginUrl"
}

function Get-GitLabUrlFromGitHttp {
    param (
        [Parameter(Mandatory=$True)]
        [String]$OriginUrl
    )

    return $OriginUrl.replace(".git", "")
}

function Get-GitLabRemoteUrl {
    param (
        [Parameter(Mandatory=$True)]
        [ValidateScript({ Test-Path $_ })]
        [String]$Repo
    )

    $originUrl = Get-GitConfigRemoteOriginUrl $Repo
    if ([String]::IsNullOrWhiteSpace($originUrl)) {
        throw "Could not find origin url"
    }

    if ($originUrl.StartsWith("git@")) {
        return Get-GitLabUrlFromGitSsh $originUrl
    } elseIf ($originUrl.StartsWith("http://") -or $originUrl.StartsWith("https://")) {
        return Get-GitLabUrlFromGitHttp $originUrl
    }

    throw "Could not parse git remote url: '$originUrl'"
}

function Get-GitLabCommitUrl {
    param (
        [Parameter(Mandatory=$True)]
        [ValidateScript({ Test-Path $_ })]
        [String]$Repo,
        [Parameter(Mandatory=$True)]
        [String]$SHA
    )

    $remoteUrl = Get-GitLabRemoteUrl -Repo $Repo
    return "$remoteUrl/commit/$SHA"
}

function Get-GitLabFileCommitUrl {
    param (
        [Parameter(Mandatory=$True)]
        [ValidateScript({ Test-Path $_ })]
        [String]$Repo,
        [Parameter(Mandatory=$True)]
        [String]$SHA,
        [Parameter(Mandatory=$True)]
        [String]$File
    )

    $remoteUrl = Get-GitLabRemoteUrl -Repo $Repo
    return "$remoteUrl/blob/$SHA/$File"
}

function Get-GitLabFileUrl {
    param (
        [Parameter(Mandatory=$True)]
        [ValidateScript({ Test-Path $_ })]
        [String]$Repo,
        [Parameter(Mandatory=$True)]
        [String]$File
    )

    $remoteUrl = Get-GitLabRemoteUrl -Repo $Repo
    $branch = Get-GitBranch -Repo $Repo
    return "$remoteUrl/blob/$branch/$File"
}

function Get-UrlViewThingsOnGitLab {
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

    if ($ViewCommit) {
        $url = Get-GitLabCommitUrl -Repo $Repo -SHA $SHA
    } elseIf($ViewFileCommit) {
        $url = Get-GitLabFileCommitUrl -Repo $Repo -SHA $SHA -File $File
    } elseIf($ViewFile) {
        $url = Get-GitLabFileUrl -Repo $Repo -File $File
    } else {
        $url = Get-GitLabRemoteUrl -Repo $Repo
    }
    return $url
}
