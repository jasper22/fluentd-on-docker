<#
.SYNOPSIS
    Script will setup and configure FluentD installation server on this computer.
    Additional information: https://docs.fluentd.org/v/0.12/
#>
function Setup-FluentD {
    [CmdletBinding(SupportsShouldProcess=$true, PositionalBinding=$false, HelpUri = 'https://github.com/ncr-swt-retail/dockertestenvironment', ConfirmImpact='Medium')]
    Param (
        # Param1 help description
        [Parameter(Position=0, Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true,ValueFromRemainingArguments=$false)]
        [string] $DownloadUri = $null
        # ,
        # # Param2 help description
        # [Parameter(Position=1, Mandatory=$false, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true,ValueFromRemainingArguments=$false)]        
        # [string] $PathAndFileNameOfDefaultConfigurationFile = $null
    )

    # Default values if passed null
    if ([string]::IsNullOrEmpty($DownloadUri)) {
        $DownloadUri = 'http://packages.treasuredata.com.s3.amazonaws.com/4/windows/td-agent-4.0.1-x64.msi'
    }

    # if ([string]::IsNullOrEmpty($PathAndFileNameOfDefaultConfigurationFile)) {
    #     $PathAndFileNameOfDefaultConfigurationFile = Join-Path $($MyInvocation.MyCommand.Module.ModuleBase) 'data\fluentd\td-agent.conf'
    # }
    
    $FLUENTD_SERVICE_NAME = 'fluentdwinsvc'

    # check if already installed 
    if (Get-Service -Name $FLUENTD_SERVICE_NAME -ErrorAction SilentlyContinue) {
        # Already installed
        Write-Host "Already installed"
    }
    else {
        # Need to install
        Write-Verbose "- Windows service named $FLUENTD_SERVICE_NAME is not found. Assume that FluentD is not installed. Trying to install now"

        $randomPath = Join-Path  $([System.Io.Path]::GetTempPath()) $([System.Io.Path]::GetRandomFileName())
        New-Item -Path $randomPath -ItemType Directory

        $tmpPath = Join-Path $randomPath 'td-agent-4.0.1-x64.msi'

        # Download
        try {
            Invoke-WebRequest -Uri $DownloadUri -OutFile $tmpPath    
        }
        catch {
            $StatusCode = $_.Exception.Response.StatusCode.value__
            
            Write-Error "Could not download TD-Agent from FluentD from: $DownloadUri. Check the url and try again"

            throw "Could not download TD-Agent from FluentD from: $DownloadUri. Check the url and try again"
        }

        Write-Host "-- Starting to install FluentD from installer"
        
        # Install 
        Start-Process -NoNewWindow -FilePath 'msiexec.exe' -ArgumentList "/i", "$tmpPath", "/qn", "/norestart" -Wait;

        Write-Host "-- Waiting a little bit for FluentD to start"
        Start-Sleep -Seconds 10

        Write-Host "-- Show status of FluentD service"
        Get-Service -Name $FLUENTD_SERVICE_NAME

        # # Replace default td-agent.conf file
        # Get-Service -Name $FLUENTD_SERVICE_NAME | Stop-Service
     
        # $TD_AGENT_DEFAULT_FILE_LOCATION = 'C:\opt\td-agent\etc\td-agent\td-agent.conf'
        # Copy-Item -Path $PathAndFileNameOfDefaultConfigurationFile -Destination $TD_AGENT_DEFAULT_FILE_LOCATION -Container -Force -Confirm:$false

        # Get-Service -Name $FLUENTD_SERVICE_NAME | Start-Service

        Write-Host "-- Done installing FluentD --"
    }
}

function Set-ConfigurationFile {
    Stop-Service fluentdwinsvc

    $hostname = [System.Net.Dns]::GetHostName()
    Write-Host "[Configure-FluentD] Hostname is: $hostname"

    $FluentDFile = @"
# This port number must match exactly the number at src\web-server\script\Configure-FluentD.ps1
<source>
    @type forward
    port 24222
    bind 0.0.0.0
    tag gposerver.log
</source>

<match **>
    @type file
    path C:\FluentDLog
</match>
"@

    Set-Content -Value $FluentDFile -Path 'C:\opt\td-agent\etc\td-agent\td-agent.conf' -Force -Encoding ascii

    Write-Host "[Configure-FluentD]  Starting service FluentD"
    Start-Service fluentdwinsvc

    Write-Host "[Configure-FluentD]  Logs received on $hostname port 24222 will be saved to C:\FluentDLog folder"
    Write-Host "[Configure-FluentD]  Done configuring FluentD"
}