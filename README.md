# AzADX

PowerShell module for Azure Data Explorer management commands

> :warning: **This module is still in beta**: Be very careful when you use it!

## Purpose of the module

As of today, you can automate the creation and of the Kusto cluster using multiple tools.
the challenge begins when you want to invoke management commands like table creation, mapping rules, or managing the access.

This often forces you to do manual work like creating a table or creating a mapping schema.
if you wanted to automate it you had to deal with API calls or other languages SDK which not always easy to automate with.

now you can automate the complete process from end to end using PowerShell.

### Prerequisites

* [PowerShell Core](https://github.com/PowerShell/PowerShell)
* Powershell [AZ Module](https://www.powershellgallery.com/packages/Az)
* PowerShell [Az Kusto Module](https://www.powershellgallery.com/packages/Az.Kusto/1.0.0)

### Installing

You can install the latest version of AzADX module from [PowerShell Gallery](https://www.powershellgallery.com/packages/AzADX)

```PowerShell
Install-Module AzADX -Scope CurrentUser -Force
```

## How to use this module

This module contain two functions:

### Invoke-AzADXMgmtCommand

#### Description

With this function you can invoke management commands on Azure Data Explorer Cluster or Database

#### Parameters

* **ClusterName** - Enter the Kusto Cluster Name
* **ResourceGroupName** -Enter the Resource Group of the Kusto Cluster
* **DatabaseName** - Enter the name of the Database you want to run your queries on
* **Command** - The management command you want to run.

#### Example

In this example you set the management command you want to run and the Database you want to run the command on.

```PowerShell
$command = ".create table AzADX ( Id:int64, Type: string, Public:bool, CreatedAt: datetime)"
$database = "AzADXDB"
Invoke-AzADXDatabaseCommand -ClusterName "" -ResourceGroupName "" -DatabaseName $database -Command $command
```

In this example you set the management command you want to run and the Database you want to run the command on.

```PowerShell
$command = ".alter cluster policy caching hot  "{\"SoftDeletePeriod\": \"10.00:00:00\", \"Recoverability\"\"Enabled\"}""
Invoke-AzADXDatabaseCommand -ClusterName "" -ResourceGroupName "" -Command $command
```

### Invoke-AzADXQuery

With this function, you can invoke queries commands on Azure Data Explorer Database or tables.

#### Parameters

* **ClusterName** - Enter the Kusto Cluster Name
* **ResourceGroupName** - Enter the Resource Group of the Kusto Cluster
* **DatabaseName** - Enter the name of the Database you want to run your queries on
* **Query** - The query you want to run.

#### Example

In this example, you query a table inside a Database.

```PowerShell
      $command = "Logs | take 10"
      $database = "AzADXDB"
      Invoke-AzADXQuery -ClusterName "" -ResourceGroupName "" -DatabaseName $database -Query $command
```
