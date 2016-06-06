$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\..\Scripts\$sut"

Describe "Parse-GitLabSsh" {
    $OriginSshUrl = "git@gitlab.example.com:group/project.git"

    Context "GitLab http" {
        Mock Check-UrlStatus { return $True }

        It "returns http link" {
            Parse-GitLabSsh $OriginSshUrl | Should BeExactly "http://gitlab.example.com/group/project"
        }

        It "could not find GitLab repo on https" {
            Assert-MockCalled Check-UrlStatus -Times 1
        }
    }

    Context "GitLab https" {
        Mock Check-UrlStatus { return $False }
        Mock Check-UrlStatus { return $True } -ParameterFilter {$Url -eq "https://gitlab.example.com/group/project"}

        It "returns http link" {
            Parse-GitLabSsh $OriginSshUrl | Should BeExactly "https://gitlab.example.com/group/project"
        }
    }

    Context "Unknown GitLab remote" {
        Mock Check-UrlStatus { return $False }

        It "throws on unknown or unreachable GitLab" {
            { Parse-GitLabSsh $OriginSshUrl } | Should Throw
        }

        It "could not find GitLab repo" {
            Assert-MockCalled Check-UrlStatus -Times 2
        }
    }
}

Describe "Parse-GitLabHttp" {
    It "returns url when http" {
        $OriginHttpUrl = "http://gitlab.example.com/group/project.git"
        Parse-GitLabHttp $OriginHttpUrl | Should BeExactly "http://gitlab.example.com/group/project"
    }

    It "returns url when https" {
        $OriginHttpsUrl = "https://gitlab.example.com/group/project.git"
        Parse-GitLabHttp $OriginHttpsUrl | Should BeExactly "https://gitlab.example.com/group/project"
    }
}

Describe "Get-GitLabRemoteUrl" {
    $Repo = "TestDrive:\repo"
    New-Item $Repo -ItemType Directory

    Context "empty origin remote" {
        Mock Get-GitConfigRemoteOriginUrl { return [String]::Empty }

        It "should throw" {
            { Get-GitLabRemoteUrl $Repo } | Should Throw "Could not find origin url"
        }
    }

    Context "origin ssh" {
        Mock Get-GitConfigRemoteOriginUrl { return "git@gitlab.example.com:group/project.git" }
        Mock Parse-GitLabSsh { return "http://gitlab.example.com/group/project" }
        Mock Parse-GitLabHttp {}

        It "should return valid url" {
            Get-GitLabRemoteUrl $Repo | Should BeExactly "http://gitlab.example.com/group/project"
        }

        It "should not parse http" {
            Assert-MockCalled Parse-GitLabHttp -Times 0
        }
    }

    Context "origin http" {
        Mock Get-GitConfigRemoteOriginUrl { return "http://gitlab.example.com/group/project.git" }
        Mock Parse-GitLabSsh {}
        Mock Parse-GitLabHttp { return "http://gitlab.example.com/group/project" }

        It "should return valid http url" {
            Get-GitLabRemoteUrl $Repo | Should BeExactly "http://gitlab.example.com/group/project"
        }

        It "should not parse ssh" {
            Assert-MockCalled Parse-GitLabSsh -Times 0
        }
    }

    Context "origin https" {
        Mock Get-GitConfigRemoteOriginUrl { return "https://gitlab.example.com/group/project.git" }
        Mock Parse-GitLabSsh {}
        Mock Parse-GitLabHttp { return "https://gitlab.example.com/group/project" }

        It "should return valid https url" {
            Get-GitLabRemoteUrl $Repo | Should BeExactly "https://gitlab.example.com/group/project"
        }

        It "should not parse ssh" {
            Assert-MockCalled Parse-GitLabSsh -Times 0
        }
    }

    Context "origin file" {
        Mock Get-GitConfigRemoteOriginUrl { return "file:////gitlab/project.git" }
        Mock Parse-GitLabSsh {}
        Mock Parse-GitLabHttp {}

        It "should return valid https url" {
            { Get-GitLabRemoteUrl $Repo } | Should Throw "Could not parse git remote url: 'file:////gitlab/project.git'"
        }

        It "should not parse ssh, http or https" {
            Assert-MockCalled Parse-GitLabSsh -Times 0
            Assert-MockCalled Parse-GitLabHttp -Times 0
        }
    }
}

Describe "Get-GitLabCommitUrl" {
    $Repo = "TestDrive:\gitlab-ce"
    New-Item $Repo -ItemType Directory
    $SHA = "410130b8077de853607b65229326f8485f575a9e"

    Mock Get-GitLabRemoteUrl { return "https://gitlab.com/gitlab-org/gitlab-ce" }

    It "returns GitLab commit url" {
        $expectedUrl = "https://gitlab.com/gitlab-org/gitlab-ce/commit/410130b8077de853607b65229326f8485f575a9e"
        Get-GitLabCommitUrl $Repo $SHA | Should BeExactly $expectedUrl
    }
}

Describe "Get-GitLabFileCommitUrl" {
    $Repo = "TestDrive:\gitlab-ce"
    New-Item $Repo -ItemType Directory
    $SHA = "535d11302e73fe88702f7c65effc3cd443bf56fc"
    $File = "app/assets/javascripts/shortcuts_issuable.coffee"

    Mock Get-GitLabRemoteUrl { return "https://gitlab.com/gitlab-org/gitlab-ce" }

    It "returns GitLab file commit url" {
        $expectedUrl = "https://gitlab.com/gitlab-org/gitlab-ce/blob/535d11302e73fe88702f7c65effc3cd443bf56fc/app/assets/javascripts/shortcuts_issuable.coffee"
        Get-GitLabFileCommitUrl $Repo $SHA $File | Should BeExactly $expectedUrl
    }
}

Describe "Get-GitLabFileUrl" {
    $Repo = "TestDrive:\gitlab-ce"
    New-Item $Repo -ItemType Directory
    $File = "Gemfile"

    Mock Get-GitLabRemoteUrl { return "https://gitlab.com/gitlab-org/gitlab-ce" }

    Context "master branch" {
        Mock Get-GitBranch { return "master" }

        It "returns GitLab file url" {
            $expectedUrl = "https://gitlab.com/gitlab-org/gitlab-ce/blob/master/Gemfile"
            Get-GitLabFileUrl $Repo $File | Should BeExactly $expectedUrl
        }
    }
}

Describe "Get-UrlViewThingsOnGitLab" {
    $Repo = "TestDrive:\gitlab-ce"
    New-Item $Repo -ItemType Directory
    $SHA = "c5b5c2e7a5872e0e4e02fbb11abed2c58bebda45"
    $File = "CHANGELOG"

    Context "view repo on GitLab" {
        $RepoUrl = "https://gitlab.com/gitlab-org/gitlab-ce"
        Mock Get-GitLabRemoteUrl { return $RepoUrl }
        Mock Get-GitLabCommitUrl {}
        Mock Get-GitLabFileCommitUrl {}
        Mock Get-GitLabFileUrl {}


        $result = Get-UrlViewThingsOnGitLab -Repo $Repo -SHA $SHA -File $File -ViewRepo

        It "get repo" {
            $result | Should Be $RepoUrl
        }

        It "could not get other views" {
            Assert-MockCalled Get-GitLabRemoteUrl -Times 1
            Assert-MockCalled Get-GitLabCommitUrl -Times 0
            Assert-MockCalled Get-GitLabFileCommitUrl -Times 0
            Assert-MockCalled Get-GitLabFileUrl -Times 0
        }

        It "get repo on default" {
            Get-UrlViewThingsOnGitLab -Repo $Repo -SHA $SHA -File $File | Should Be $RepoUrl
        }
    }

    Context "view commit on GitLab" {
        $CommitUrl = "https://gitlab.com/gitlab-org/gitlab-ce/commit/c5b5c2e7a5872e0e4e02fbb11abed2c58bebda45"
        Mock Get-GitLabRemoteUrl {}
        Mock Get-GitLabCommitUrl { return $CommitUrl }
        Mock Get-GitLabFileCommitUrl {}
        Mock Get-GitLabFileUrl {}

        $result = Get-UrlViewThingsOnGitLab -Repo $Repo -SHA $SHA -File $File -ViewCommit

        It "get commit" {
            $result | Should Be $CommitUrl
        }

        It "could not get other views" {
            Assert-MockCalled Get-GitLabRemoteUrl -Times 0
            Assert-MockCalled Get-GitLabCommitUrl -Times 1
            Assert-MockCalled Get-GitLabFileCommitUrl -Times 0
            Assert-MockCalled Get-GitLabFileUrl -Times 0
        }
    }

    Context "view file commit on GitLab" {
        $FileCommitUrl = "https://gitlab.com/gitlab-org/gitlab-ce/blob/c5b5c2e7a5872e0e4e02fbb11abed2c58bebda45/CHANGELOG"
        Mock Get-GitLabRemoteUrl {}
        Mock Get-GitLabCommitUrl {}
        Mock Get-GitLabFileCommitUrl { return $FileCommitUrl }
        Mock Get-GitLabFileUrl {}

        $result = Get-UrlViewThingsOnGitLab -Repo $Repo -SHA $SHA -File $File -ViewFileCommit

        It "get file commit" {
            $result | Should Be $FileCommitUrl
        }

        It "could not get other views" {
            Assert-MockCalled Get-GitLabRemoteUrl -Times 0
            Assert-MockCalled Get-GitLabCommitUrl -Times 0
            Assert-MockCalled Get-GitLabFileCommitUrl -Times 1
            Assert-MockCalled Get-GitLabFileUrl -Times 0
        }
    }

    Context "view file on GitLab" {
        $FileUrl = "https://gitlab.com/gitlab-org/gitlab-ce/blob/master/CHANGELOG"
        Mock Get-GitLabRemoteUrl {}
        Mock Get-GitLabCommitUrl {}
        Mock Get-GitLabFileCommitUrl {}
        Mock Get-GitLabFileUrl { return $FileUrl }

        $result = Get-UrlViewThingsOnGitLab -Repo $Repo -SHA $SHA -File $File -ViewFile

        It "get file" {
            $result | Should Be $FileUrl
        }

        It "could not get other views" {
            Assert-MockCalled Get-GitLabRemoteUrl -Times 0
            Assert-MockCalled Get-GitLabCommitUrl -Times 0
            Assert-MockCalled Get-GitLabFileCommitUrl -Times 0
            Assert-MockCalled Get-GitLabFileUrl -Times 1
        }
    }
}
