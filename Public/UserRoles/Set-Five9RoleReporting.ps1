function Set-Five9RoleReporting
{
    <#
    .SYNOPSIS
    
        Function used to modify a user's reporting role

    .EXAMPLE
    
        Set-Five9UserReportingRole -Username 'jdoe@domain.com' -FullPermissions $true
    
        # Grants user 'jdoe@domain.com' all reporting rights

    .EXAMPLE
    
        Set-Five9UserReportingRole -Username 'jdoe@domain.com' -CanViewSocialReports $false -CanViewCannedReports $true
    
        # Modifies reporting rights for user 'jdoe@domain.com'

    .LINK

        Add-Five9Role
        Remove-Five9Role
        Set-Five9RoleAdmin
        Set-Five9RoleAgent
        Set-Five9RoleSupervisor

    #>

    [CmdletBinding(DefaultParametersetName='Username',PositionalBinding=$false)]
    param
    (
        # Username of the user being modified
        # This parameter is not used when -UserProfileName is passed
        [Parameter(ParameterSetName='Username',Mandatory=$true)][string]$Username,

        # Profile name being modified
        # This parameter is not used when -Username is passed
        [Parameter(ParameterSetName='UserProfileName',Mandatory=$true)][string]$UserProfileName,
        
        # If set to $true, user will be granted full reporting permissions 
        [Parameter(Mandatory=$false)][bool]$FullPermissions,

        [Parameter(Mandatory=$false)][bool]$CanViewDashboards,
        [Parameter(Mandatory=$false)][bool]$CanViewAllSkills,
        [Parameter(Mandatory=$false)][bool]$CanViewAllGroups,
        [Parameter(Mandatory=$false)][bool]$CanAccessRecordingsColumn,
        [Parameter(Mandatory=$false)][bool]$CanScheduleReportsViaFtp,
        [Parameter(Mandatory=$false)][bool]$CanViewStandardReports,
        [Parameter(Mandatory=$false)][bool]$CanViewSocialReports,
        [Parameter(Mandatory=$false)][bool]$CanViewCustomReports,
        [Parameter(Mandatory=$false)][bool]$CanViewScheduledReports,
        [Parameter(Mandatory=$false)][bool]$CanViewRecentReports,
        [Parameter(Mandatory=$false)][bool]$CanViewRelease7Reports,
        [Parameter(Mandatory=$false)][bool]$CanViewCannedReports

    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $objToModify = $null
        try
        {
            if ($PsCmdLet.ParameterSetName -eq "Username")
            {
                $objToModify = $global:DefaultFive9AdminClient.getUsersInfo($Username)
            }
            elseif ($PsCmdLet.ParameterSetName -eq "UserProfileName")
            {
                $objToModify = $global:DefaultFive9AdminClient.getUserProfile($UserProfileName)
            }
            else
            {
                throw "Error setting media type. ParameterSetName not set."
            }

        }
        catch
        {

        }


        if ($objToModify.Count -gt 1)
        {
            throw "Multiple matches were found using query: ""$($Username)$($UserProfileName)"". Please try using the exact name of the user or profile you're trying to modify."
            return
        }

        if ($objToModify -eq $null)
        {
            throw "Cannot find a Five9 user or profile with name: ""$($Username)$($UserProfileName)"". Remember that this value is case sensitive."
            return
        }

        $objToModify = $objToModify | Select-Object -First 1

        if ($objToModify.roles.reporting -eq $null)
        {
            throw "Reporting role has not yet been added. Please use Add-Five9Role to add reporting role, and then try again."
            return
        }


        if ($FullPermissions -eq $true)
        {
            $allPermissions = $objToModify.roles.reporting.type

            foreach ($permission in $allPermissions)
            {
                ($objToModify.roles.reporting | ? {$_.type -eq $permission}).value = $true
                ($objToModify.roles.reporting | ? {$_.type -eq $permission}).typeSpecified = $true
            }

            $roleToModify = New-Object PSFive9Admin.userRoles
            $roleToModify.reporting = @($objToModify.roles.reporting)


        }
        else
        {
            # get parameters passed that are part of the permissions array in the supervsior user role
            $permissionKeysPassed = @($PSBoundParameters.Keys | ? {$objToModify.roles.reporting.type -contains $_ })

            # if no parameters were passed that change the reporting role, abort
            if ($permissionKeysPassed.Count -eq 0)
            {
                throw "No parameters were passed to modify reporting role."
                return
            }


            # set values in permissions array based on parameters passed
            foreach ($key in $permissionKeysPassed)
            {
                ($objToModify.roles.reporting | ? {$_.type -eq $key}).typeSpecified = $true
                ($objToModify.roles.reporting | ? {$_.type -eq $key}).value = $PSBoundParameters[$key]
            }

            $roleToModify = New-Object PSFive9Admin.userRoles
            $roleToModify.reporting = @($objToModify.roles.reporting)


        }

        if ($PsCmdLet.ParameterSetName -eq "Username")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying 'Reporting' role on user '$Username'." 
            $response = $global:DefaultFive9AdminClient.modifyUser($objToModify.generalInfo, $roleToModify, $null)
        }
        elseif ($PsCmdLet.ParameterSetName -eq "UserProfileName")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying 'Reporting' role on user profile '$UserProfileName'." 
            $response = $global:DefaultFive9AdminClient.modifyUserProfile($objToModify)
        }

    }
    catch
    {
        throw $_
    }
}
