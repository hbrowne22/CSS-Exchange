# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

. $PSScriptRoot\..\..\Helpers\Get-HCDefaultSBInjection.ps1
. $PSScriptRoot\..\..\..\..\Shared\Get-ExchangeBuildVersionInformation.ps1
. $PSScriptRoot\..\..\..\..\Shared\CompareExchangeBuildLevel.ps1

function Add-JobExchangeInformationLocal {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ComputerName,

        [Parameter(Mandatory = $true)]
        [object]$GetExchangeServer,

        [Parameter(Mandatory = $true)]
        [ValidateSet("Legacy", "Queue", "StartNow")]
        [string]$RunType
    )
    process {

        . $PSScriptRoot\Invoke-JobExchangeInformationLocal.ps1

        Write-Verbose "Calling: $($MyInvocation.MyCommand)"
        $nonDefaultSbDependencies = @(
            ${Function:GetExchangeBuildDictionary},
            ${Function:GetValidatePossibleParameters},
            ${Function:ValidateCUParameter},
            ${Function:ValidateSUParameter},
            ${Function:ValidateVersionParameter},
            ${Function:Get-ExchangeBuildVersionInformation},
            ${Function:Get-RemoteRegistrySubKey},
            ${Function:Get-RemoteRegistryValue},
            ${Function:Test-ExchangeBuildGreaterOrEqualThanSecurityPatch}
        )

        if ($RunType -eq "Legacy") {
            throw "Legacy Not Implemented"
        } else {
            $sbInjectionParams = @{
                PrimaryScriptBlock = ${Function:Invoke-JobExchangeInformationLocal}
                IncludeScriptBlock = $nonDefaultSbDependencies
            }
            $scriptBlock = Get-HCDefaultSBInjection @sbInjectionParams
            $params = @{
                JobParameter = @{
                    ComputerName = $ComputerName
                    ScriptBlock  = $scriptBlock
                    ArgumentList = $GetExchangeServer
                }
                JobId        = "Invoke-JobExchangeInformationLocal-$ComputerName"
                TryStartNow  = $RunType -eq "StartNow"
            }
            Add-JobQueue @params
        }
    }
}
