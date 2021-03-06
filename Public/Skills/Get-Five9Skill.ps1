function Get-Five9Skill
{
    <#
    .SYNOPSIS
    
        Function used to get Skill objects from Five9
   
    .EXAMPLE
    
        Get-Five9Skill
    
        # Returns all skills
    
    .EXAMPLE
    
        Get-Five9Skill -NamePattern "MultiMedia"
    
        # Returns all skills matching the string "MultiMedia"
    #>
    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Returns only skills matching a given regex string
        # If omitted, all skills will be returned
        [Parameter(Mandatory=$false)][string]$NamePattern = '.*'
    )
    
    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning skills matching pattern '$NamePattern'" 
        return $global:DefaultFive9AdminClient.getSkills($NamePattern) | sort name

    }
    catch
    {
        throw $_
    }
}



