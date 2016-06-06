$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\..\Scripts\$sut"

Describe "Check-UrlStatus" {
    Context "valid url" {
        $ValidUrl = "http://example.com"
        Mock Get-WebRequestStatusCode { return 200 }

        It "should return true when url exists" {
            Check-UrlStatus $ValidUrl | Should Be $True
        }
    }

    Context "not valid url" {
        $NotValidUrl = "http://example.co"

        Mock Invoke-WebRequest { throw [Net.WebException]"The remote name could not be resolved" }

        It "should return false when url not resolved" {
            Check-UrlStatus $NotValidUrl | Should Be $False
        }
    }

    Context "not existing page" {
        $NotExistingPageUrl = "http://example.com/notexist.html"
        Mock Get-WebRequestStatusCode { return 404 }

        It "should return false when page not exists" {
            Check-UrlStatus $NotExistingPageUrl | Should Be $False
        }
    }
}
