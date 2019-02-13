[CmdletBinding()]
param(
    [Parameter()]
    [string]
    $CmdletModule = (Join-Path -Path $PSScriptRoot `
                                         -ChildPath "..\Stubs\Office365DSC.psm1" `
                                         -Resolve)
)

Import-Module -Name (Join-Path -Path $PSScriptRoot `
                                -ChildPath "..\UnitTestHelper.psm1" `
                                -Resolve)

$Global:DscHelper = New-O365DscUnitTestHelper -StubModule $CmdletModule `
                                                -DscResource "SPOSite"

Describe -Name $Global:DscHelper.DescribeHeader -Fixture {
    InModuleScope -ModuleName $Global:DscHelper.ModuleName -ScriptBlock {
        Invoke-Command -ScriptBlock $Global:DscHelper.InitializeScript -NoNewScope

        $secpasswd = ConvertTo-SecureString "test@password1" -AsPlainText -Force
        $GlobalAdminAccount = New-Object System.Management.Automation.PSCredential ("tenantadmin", $secpasswd)

        Mock -CommandName Test-SecurityAndComplianceCenterConnection -MockWith {

        }

        # Test contexts
        Context -Name "Set-TargetResource When the Unified Audit Log Ingestion is Disabled" -Fixture {
            $testParams = @{
                IsSingleInstance                = 'Yes'
                UnifiedAuditLogIngestionEnabled = 'Enabled'
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName Get-AdminAuditLogConfig -MockWith {
                return $null
            }

            It "Should return false from the Get method" {
                (Get-TargetResource @testParams).UnifiedAuditLogIngestionEnabled | Should Be $false
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Enables UnifiedAuditLogIngestionEnabled in the Set method" {
                Set-TargetResource @testParams
            }
        }

        Context -Name "Set-TargetResource When the Unified Audit Log Ingestion is Enabled" -Fixture {
            $testParams = @{
                IsSingleInstance                = 'Yes'
                UnifiedAuditLogIngestionEnabled = 'Disabled'
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName Get-AdminAuditLogConfig -MockWith {
                return $null
            }

            It "Should return false from the Get method" {
                (Get-TargetResource @testParams).UnifiedAuditLogIngestionEnabled | Should Be $true
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $false
            }

            It "Enables UnifiedAuditLogIngestionEnabled in the Set method" {
                Set-TargetResource @testParams
            }
        }


        Context -Name "Test Passes When the Unified Audit Log Ingestion is Disabled" -Fixture {
            $testParams = @{
                IsSingleInstance                = 'Yes'
                UnifiedAuditLogIngestionEnabled = 'Disabled'
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName Get-AdminAuditLogConfig -MockWith {
                return $null
            }

            It "Should return false from the Get method" {
                (Get-TargetResource @testParams).UnifiedAuditLogIngestionEnabled | Should Be $false
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }

        }

        Context -Name "Test Passes When the Unified Audit Log Ingestion is Enabled" -Fixture {
            $testParams = @{
                IsSingleInstance                = 'Yes'
                UnifiedAuditLogIngestionEnabled = 'Enabled'
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName Get-AdminAuditLogConfig -MockWith {
                return $null
            }

            It "Should return false from the Get method" {
                (Get-TargetResource @testParams).UnifiedAuditLogIngestionEnabled | Should Be $true
            }

            It "Should return false from the Test method" {
                Test-TargetResource @testParams | Should Be $true
            }

        }

        Context -Name "ReverseDSC Tests" -Fixture {
            $testParams = @{
                IsSingleInstance                = 'Yes'
                UnifiedAuditLogIngestionEnabled = 'Enabled'
                GlobalAdminAccount = $GlobalAdminAccount
            }

            Mock -CommandName Get-AdminAuditLogConfig -MockWith {
                return @{
                    UnifiedAuditLogIngestionEnabled = $true
                }
            }

            It "Should Reverse Engineer resource from the Export method" {
                Export-TargetResource @testParams
            }
        }
    }
}

Invoke-Command -ScriptBlock $Global:DscHelper.CleanupScript -NoNewScope
