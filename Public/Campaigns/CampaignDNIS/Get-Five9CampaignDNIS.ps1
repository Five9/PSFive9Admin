function Get-Five9CampaignDNIS
{
    <#
    .SYNOPSIS
    
        Function to returns the list of DNIS associated with an inbound campaign

    .EXAMPLE
    
        Get-Five9CampaignDNIS -Name 'Hot-Leads'

        # Returns the list of DNIS associated with a campaign
    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    ( 
        # Inbound campaign name
        [Parameter(Mandatory=$true)][string]$Name
    )

    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Returning DNIS associated with campaign '$Name'." 
        return $global:DefaultFive9AdminClient.getCampaignDNISList($Name)

    }
    catch
    {
        throw $_
    }
}
