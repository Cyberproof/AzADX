#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}, @{ModuleName = 'Az.Kusto'; ModuleVersion = '1.0.0'}
#requires -version 6.2
function Get-KustoCluster {
    <#
    .SYNOPSIS
    Get Kusto Cluster
    .DESCRIPTION
    This function is used by other function for getting the Kusto cluster and setting the values for $script:authHeader and $script:baseUri
    .PARAMETER ClusterName
    Enter the Kusto Cluster Name
    .PARAMETER ResourceGroupName
    Enter the Kusto Cluster Resource Group Name
    .EXAMPLE
    Get-KustoCluster -ResourceGroup "Az-ADX-rg" -ClusterName "Az-ADX-Cluster01"
    This example will get the Kusto Cluster and set BaseUri and AuthHeader param on Script scope level
    .NOTES
    NAME: Get-KustoCluster
    #>
    param (
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string] $ClusterName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName

    )

    begin {
    }

    process {
        if ($ClusterName) {
            Write-Verbose "Getting the URI for the cluster $($ClusterName)"
            $uri = (Get-AzKustoCluster -Name $ClusterName -ResourceGroupName $ResourceGroupName).Uri
            $Clusterhostname = ([System.Uri]"$($uri)").Host
        }
        else {
            Write-Error "Unable to find workspace $ClusterName under the resource group: $($ResourceGroupName) " -ErrorAction Stop
        }
        if ($uri) {
            Write-Verbose "Kusto server Uri is: $($uri)"
            $script:baseUri = $uri

            $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
            $script:token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, $uri).AccessToken

            $script:authHeader = @{
                'Content-Type' = 'application/json'
                Authorization  = 'Bearer ' + $script:token
                host           = $Clusterhostname
            }
        }
    }
    
}