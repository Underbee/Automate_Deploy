$DirectoryToCreate = "C:\temp"

<# install Net Frame 4.8#>
$DownloadNET = "https://github.com/Underbee/Automate_Deploy/raw/main/dotNetFx35setup.exe"
$SoftwareNETPath = "C:\Temp\Netframe.exe"
if (-not (Test-Path -LiteralPath $DirectoryToCreate)) {
    mkdir "C:\temp"
} Try {
    Write-Host "Downloading from: $($DownloadNET)"
    Write-Host "Downloading to:   $($SoftwareNETPath)"
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($DownloadNET, $SoftwareNETPath)
    Write-Host "Download Complete"
$process = (Start-Process -FilePath $SoftwareNETPath -ArgumentList "/q /norestart" -Wait -Verb RunAs -PassThru)
Write-Host -Fore Red "Errorcode: " $process.ExitCode
} catch {
    Write-Host "Error in creating temp Folder! Error: " $process.ExitCode
    }
<# End of NetFrame Work Install #>

<# Install Automate#>
$DownloadPath = "https://github.com/Underbee/Automate_Deploy/raw/main/Agent_Install.exe"
$SoftwarePath = "C:\Temp\Automate_Agent.exe"

    Write-Host "Downloading from: $($DownloadPath)"
    Write-Host "Downloading to:   $($SoftwarePath)"
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile($DownloadPath, $SoftwarePath)
    Write-Host "Download Complete"

$InstallExitCode = (Start-Process -FilePath $SoftwarePath -ArgumentList "/quiet /norestart" -Wait -Verb RunAs -PassThru)
If ($InstallExitCode -eq 0) {
    If (!$Silent) {Write-Verbose "The Automate Agent Installer Executed Without Errors"}
} Else {
    Write-Host "Automate Installer Exit Code: $InstallExitCode" -ForegroundColor Red
    Write-Host "Automate Installer Logs: $LogFullPath" -ForegroundColor Red
    Write-Host "The Automate MSI failed. Waiting 15 Seconds..." -ForegroundColor Red
    $Date = (get-date -UFormat %Y-%m-%d_%H-%M-%S)
    $LogFullPath = "$env:windir\Temp\Automate_Agent_$Date.log"
    $InstallExitCode = (Start-Process -FilePath $SoftwarePath -ArgumentList "/quiet /norestart" -Wait -Verb RunAs -PassThru)
    Write-Host "Automate Installer Exit Code: $InstallExitCode" -ForegroundColor Yellow
    Write-Host "Automate Installer Logs: $LogFullPath" -ForegroundColor Yellow
}# End Else
