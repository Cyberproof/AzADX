#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}, @{ModuleName = 'Az.Kusto'; ModuleVersion = '1.0.0'}
#requires -version 6.2

function Invoke-AzADXMgmtCommand {
    <#
      .SYNOPSIS
      Invoke AzADXCommand
      .DESCRIPTION
      With this function you can invoke management commands on Azure Data Explorer Cluster or Database
      .PARAMETER ClusterName
      Enter the Kusto Cluster Name
      .PARAMETER ResourceGroupName
      Enter the Resource Group of the Kusto Cluster
      .PARAMETER DatabaseName
      Enter the name of the Database you want to run your queries on
      .PARAMETER Command
      The command you want to run.
      .EXAMPLE
      $command = ".create table AzADX ( Id:int64, Type: string, Public:bool, CreatedAt: datetime)"
      $database = "AzADXDB"
      Invoke-AzADXDatabaseCommand -ClusterName "" -ResourceGroupName "" -DatabaseName $database -Command $command

      In this example you set the management command you want to run and the Database you want to run the command on.
      .EXAMPLE
      $command = ".alter cluster policy caching hot  "{\"SoftDeletePeriod\": \"10.00:00:00\", \"Recoverability\": \"Enabled\"}""
      Invoke-AzADXDatabaseCommand -ClusterName "" -ResourceGroupName "" -Command $command

      In this example you set the management command you want to run and the Database you want to run the command on.
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ClusterName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName,

        [Parameter(Mandatory = $true,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Command
    )

    begin {
    }

    process {
        $arguments = @{
            ClusterName       = $ClusterName
            ResourceGroupName = $ResourceGroupName
        }
        try {
            Get-KustoCluster @arguments -ErrorAction Stop
        }
        catch {
            Write-Error $_.Exception.Message
            break
        }
        $Uri = "$($script:baseUri)/v1/rest/mgmt"
        Write-Verbose -Message "Using URI: $($uri)"

        if ($DatabaseName) {
            $CommandtoExecute = @{
                csl = $Command
                db  = $DatabaseName
            }
        }
        else {
            $CommandtoExecute = @{
                csl = $Command
            }
        }

        try {
            $Invoke = Invoke-RestMethod -Uri $Uri -Body (ConvertTo-Json $CommandtoExecute) -Method Post -Headers $script:authHeader
        }
        catch {
            Write-Verbose $Invoke
            Write-Error "Unable to invoke-command with error code: $($_.Exception.Message)" -ErrorAction Stop
        }

    }
}
