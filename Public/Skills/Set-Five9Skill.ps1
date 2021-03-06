function Set-Five9Skill
{
    <#
    .SYNOPSIS
    
        Function used to modify a skill

    .EXAMPLE
    
        Set-Five9Skill -Name "MultiMedia" -Description "Skill used for MultiMedia" -RouteVoiceMails: $true
    
        # Modifies the skill MultiMedia's properties

    #>
    [CmdletBinding(PositionalBinding=$false)]
    param
    (
        # Skill name
        [Parameter(Mandatory=$true, Position=0)][string]$Name,

        # New description
        [Parameter(Mandatory=$false)][string]$Description,

        # Whether to route voicemail messages to the skill
        [Parameter(Mandatory=$false)][bool]$RouteVoiceMails
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        $skill = New-Object PSFive9Admin.skill
        $skill.name = $Name
        $skill.description = $Description

        if ($RouteVoiceMails -eq $true)
        {
            $skill.routeVoiceMailsSpecified = $true
            $skill.routeVoiceMails = $true
        }
        elseif ($RouteVoiceMails -eq $false)
        {
            $skill.routeVoiceMailsSpecified = $true
            $skill.routeVoiceMails = $false
        }

        Write-Verbose "$($MyInvocation.MyCommand.Name): Modifying skill '$Name'."
        $response = $global:DefaultFive9AdminClient.modifySkill($skill)

        return $response.skill

    }
    catch
    {
        throw $_
    }
}
