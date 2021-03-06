function Set-Five9RoleAdmin
{
    <#
    .SYNOPSIS
    
        Function used to modify a user's admin role

    .EXAMPLE
    
        Set-Five9UserAdminRole -Username 'jdoe@domain.com' -FullPermissions $true
    
        # Grants user 'jdoe@domain.com' full admin rights

    .EXAMPLE
    
        Set-Five9UserAdminRole -Username 'jdoe@domain.com' -ManageSkills $false -EditConnectors $false -AccessConfigANI $true
    
        # Modifies admin rights for user 'jdoe@domain.com'

    .LINK

        Add-Five9Role
        Remove-Five9Role
        Set-Five9RoleAgent
        Set-Five9RoleReporting
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
        
        # If set to $true, user will be granted full admin permissions including the ability to edit other administrators
        [Parameter(Mandatory=$false)][bool]$FullPermissions,

        [Parameter(Mandatory=$false)][bool]$EditIvr,
        [Parameter(Mandatory=$false)][bool]$EditWorkflowRules,
        [Parameter(Mandatory=$false)][bool]$EditTrustedIPAddresses,
        [Parameter(Mandatory=$false)][bool]$EditReasonCodes,
        [Parameter(Mandatory=$false)][bool]$ManageCampaignsReset,
        [Parameter(Mandatory=$false)][bool]$EditPrompts,
        [Parameter(Mandatory=$false)][bool]$ManageLists,
        [Parameter(Mandatory=$false)][bool]$ManageCampaignsStartStop,
        [Parameter(Mandatory=$false)][bool]$ManageSkills,
        [Parameter(Mandatory=$false)][bool]$EditDispositions,
        [Parameter(Mandatory=$false)][bool]$ManageCampaignsResetListPosition,
        [Parameter(Mandatory=$false)][bool]$EditProfiles,
        [Parameter(Mandatory=$false)][bool]$EditDomainEMailNotification,
        [Parameter(Mandatory=$false)][bool]$ManageDNC,
        [Parameter(Mandatory=$false)][bool]$EditConnectors,
        [Parameter(Mandatory=$false)][bool]$EditCallAttachedData,
        [Parameter(Mandatory=$false)][bool]$EditCampaignEMailNotification,
        [Parameter(Mandatory=$false)][bool]$AccessConfigANI,
        [Parameter(Mandatory=$false)][bool]$ManageCampaignsProperties,
        [Parameter(Mandatory=$false)][bool]$ManageCampaignsResetDispositions,
        [Parameter(Mandatory=$false)][bool]$ManageUsers,
        [Parameter(Mandatory=$false)][bool]$ManageCRM,
        [Parameter(Mandatory=$false)][bool]$ManageAgentGroups
        #[Parameter(Mandatory=$false)][bool]$AccessBillingApplication, # field cannot be set
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

        if ($objToModify.roles.admin -eq $null)
        {
            throw "Admin role has not yet been added. Please use Add-Five9Role to add Admin role, and then try again."
            return
        }

        if ($FullPermissions -eq $true)
        {
            $adminPermission = New-Object PSFive9Admin.adminPermission
            $adminPermission.type = 'FullPermissions'
            $adminPermission.typeSpecified = $true
            $adminPermission.value = $true

            $roleToModify = New-Object PSFive9Admin.userRoles
            $objToModify.admin = @($adminPermission)


        }
        else
        {
            # get parameters passed that are part of the permissions array in the admin user role
            $permissionKeysPassed = @($PSBoundParameters.Keys | ? {$_ -ne 'FullPermissions' -and $objToModify.roles.admin.type -contains $_ })

            # if no parameters were passed that change the admin role, abort
            if ($permissionKeysPassed.Count -eq 0)
            {
                throw "No parameters were passed to modify admin role."
                return
            }


            # set values in permissions array based on parameters passed
            foreach ($key in $permissionKeysPassed)
            {
                ($objToModify.roles.admin | ? {$_.type -eq $key}).typeSpecified = $true
                ($objToModify.roles.admin | ? {$_.type -eq $key}).value = $PSBoundParameters[$key]
            }


            $roleToModify = New-Object PSFive9Admin.userRoles
            $roleToModify.admin = $objToModify.roles.admin | ? {$_.type -ne "AccessBillingApplication"}

        }

        
        if ($PsCmdLet.ParameterSetName -eq "Username")
        {
            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying 'Admin' role on user '$Username'." 
            $response = $global:DefaultFive9AdminClient.modifyUser($objToModify.generalInfo, $roleToModify, $null)
        }
        elseif ($PsCmdLet.ParameterSetName -eq "UserProfileName")
        {
            $objToModify.roles.admin = $roleToModify.admin
            Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying 'Admin' role on user profile '$UserProfileName'." 
            $response = $global:DefaultFive9AdminClient.modifyUserProfile($objToModify)
        }


    }
    catch
    {
        throw $_
    }
}
