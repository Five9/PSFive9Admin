function Remove-Five9CampaignDisposition
{
    <#
    .SYNOPSIS
    
        Function removes disposition(s) from a Five9 campaign

    .EXAMPLE
    
        Remove-Five9CampaignDisposition -Name 'MultiMedia' -DispositionName 'Wrong Number'

        # Removes a single disposition from a campaign

    .EXAMPLE

        $dispositionsToBeRemoved = @('Dead Air', 'Wrong Number')
        Remove-Five9CampaignDisposition -Name 'MultiMedia' -DispositionName $dispositionsToBeRemoved
    
        # Removes multiple dispositions from a campaign

    #>

    [CmdletBinding(PositionalBinding=$true)]
    param
    (
        # Campaign that disposition(s) will be removed from
        [Parameter(Mandatory=$true)][string]$Name,

        # Single disposition name, or multiple disposition names to be added removed from a campaign
        [Parameter(Mandatory=$true)][string[]]$DispositionName
    )
    try
    {
        Test-Five9Connection -ErrorAction: Stop

        Write-Verbose "$($MyInvocation.MyCommand.Name): Removing dispostion from campaign '$Name'." 
        return $global:DefaultFive9AdminClient.removeDispositionsFromCampaign($Name, $DispositionName)

    }
    catch
    {
        throw $_
    }

}

