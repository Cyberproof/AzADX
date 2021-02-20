#requires -module @{ModuleName = 'Az.Accounts'; ModuleVersion = '1.5.2'}, @{ModuleName = 'Az.Kusto'; ModuleVersion = '1.0.0'}
#requires -version 6.2


function Get-AzADXSchema {
    <#
      .SYNOPSIS
      Get Az ADX Schema
      .DESCRIPTION
      With this function you can get Log Analytics Workspace table and generate ADX Schema and Mapping Rule
      .PARAMETER WorkspaceID
      Enter the Workspace ID that holds the table
      .PARAMETER TableName
      Enter the table name you want to generate schema or mapping rule
      .PARAMETER GetMappingRule
      Switch, add this to get the mapping rule
      .PARAMETER GetTableSchema
      Switch, add this to get table schema
      .EXAMPLE
      $WorkspaceID = "XXXX-XXX-XXX-XXXX"
      $TableName = "TestTable"
      Get-AzADXSchema -WorkspaceID $WorkspaceID -TableNAme $TableNAme -GetTableSchema

      In this example the function will get the Schema of the table you provide and output the schema ready for ADX.
      .EXAMPLE
      $WorkspaceID = "XXXX-XXX-XXX-XXXX"
      $TableName = "TestTable"
      Get-AzADXSchema -WorkspaceID $WorkspaceID -TableNAme $TableNAme -GetTableSchema

      In this example the function will get the Schema of the table you provide and output the mapping rule ready for ADX.
    #>

    [cmdletbinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $WorkspaceID,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $TableName,

        [Parameter(Mandatory = $false)]
        [switch]$GetMappingRule,

        [Parameter(Mandatory = $false)]
        [switch]$GetTableSchema
    )
    #Region GetSchema
    $Query = @"
    $tablename | getschema
"@
    try {
        $GetSchema = Invoke-AzOperationalInsightsQuery -WorkspaceId $WorkspaceID -Query $Query
    }
    catch {
        Write-Error $_.Exception.Message
        break
    }

    Foreach ($field in $GetSchema.Results) {
        if ($field.ColumnName -eq $GetSchema.Results.ColumnName[0]) {
            $schema += "($($field.ColumnName):$($field.ColumnType), "
        }
        elseif ($field.ColumnName -eq $GetSchema.Results.ColumnName[-1]) {
            $schema += "$($field.ColumnName):$($field.ColumnType))"
        }
        else {
            $schema += "$($field.ColumnName):$($field.ColumnType), "
        }
    }
    #EndRegion GetSchema

    #Region Get Mapping Rule
    $MappingRule = $GetSchema.Results | Select-Object @{name = "Column" ; expression = { $($_.ColumnName) } }, @{name = "Properties" ; expression = { "{" + '\"Path\"' + ":" + '\"' + "$." + "$($_.ColumnName)\" + '"}'}}
    Foreach ($field in $MappingRule) {
        if ($field.Column -eq $MappingRule.Column[0]) {
            $Mapping += "'[" + '{"column":' + '"' + "$($field.Column)" + '",' + '"Properties":' + $field.Properties + "},"
        }
        elseif ($field.Column -eq $MappingRule.Column[-1]) {
            $Mapping += '{"column":'+ '"' + "$($field.Column)" + '",' + '"Properties":' + $field.Properties + "}]'"
        }
        else {
            $Mapping += '{"column":'+ '"' + "$($field.Column)" + '",' + '"Properties":' + $field.Properties + "},"
        }
    }
    #EndRegion Get Mapping Rule

    if ($GetMappingRule){
        return $MappingRule
    }

    if ($GetTableSchema){
        return $schema
    }
}
