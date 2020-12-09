Try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $params = @{
            Path        = ('.\AzADX' -f $PSScriptRoot )
            NuGetApiKey = $env:psgkey
            ErrorAction = 'Stop'
        }
        Publish-Module @params
        Write-Output -InputObject ('AzADX PowerShell Module version published to the PowerShell Gallery!')
    }
    Catch {
        throw $_
    }