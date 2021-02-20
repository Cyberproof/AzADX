#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}, @{ModuleName = 'Az.Kusto'; ModuleVersion = '1.0.0'}
#requires -version 6.2

function Invoke-AzADXQuery {
    <#
      .SYNOPSIS
      Invoke AzADXQuery
      .DESCRIPTION
      With this function you can invoke queries commands on Azure Data Explorer Database
      .PARAMETER ClusterName
      Enter the Kusto Cluster Name
      .PARAMETER ResourceGroupName
      Enter the Resource Group of the Kusto Cluster
      .PARAMETER DatabaseName
      Enter the name of the Database you want to run your queries on
      .PARAMETER Query
      The query you want to run.
      .EXAMPLE
      $command = "Logs | take 10"
      $database = "AzADXDB"
      Invoke-AzADXDatabaseCommand -ClusterName "" -ResourceGroupName "" -DatabaseName $database -Command $command

      In this example you set query command you want to run and the Database you want to run the query on.
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ClusterName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ResourceGroupName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName,

        [Parameter(Mandatory = $true,
            ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Query
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
        $Uri = "$($script:baseUri)/v1/rest/query"
        Write-Verbose -Message "Using URI: $($uri)"

        if ($DatabaseName) {
            $CommandtoExecute = @{
                csl = $Query
                db  = $DatabaseName
            }
        }
        else {
            $CommandtoExecute = @{
                csl = $Query
            }
        }

        $CommandUri = "$($uri)?csl=$($Query)&db=$($DatabaseName)"

        try {
            $Invoke = Invoke-RestMethod -Uri $CommandUri -Method Get -Headers $script:authHeader
        }
        catch {
            Write-Verbose $_
            Write-Error "Unable to invoke-command with error code: $($_.Exception.Message)" -ErrorAction Stop
        }
        $result = @()
        if ($Invoke) {
            $table = $Invoke.Tables | Where-Object { $_.TableName -eq "Table_0" }
            $Rows = $table.Rows[0].Count
            $events = $table.Rows.Count

            for ($i = 0; $i -lt $events; $i++) {
                $parsedrow = [PSCustomObject]@{}
                for ($j = 0; $j -lt $Rows; $j++) {
                    $parsedrow | Add-Member -NotePropertyName "$($table.columns[$j].ColumnName)" -NotePropertyValue "$($table.Rows[$i][$j])"
                }
                $result += $parsedrow

            }
        }
        return $result

    }
}
