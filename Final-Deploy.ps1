$url = "https://github.com/Underbee/Automate_Deploy/raw/main/Agent_Install.MSI"
$output = "C:\Users\admin\desktop\Automate-Module\Automate.msi"

    <# Install Automate#>

#if (-not (Test-Path C:\Support -PathType Container)) {
    #Try {
       # mkdir "C:\Support"
       # takeown.exe /F C:\Support /A /R /D Y

#}
    #catch {Write-Error -Message "Unable to create Automate Directory, Download impossible!"}
#"Folder-Created!"


<# TLS/SSL Update before Internet Download #>

if ( -not ("TrustAllCertsPolicy" -as [type])) {
    Add-Type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
    ServicePoint srvPoint, X509Certificate certificate,
    WebRequest request, int certificateProblem) { return true; }
"@}

[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'

<# Internet Download Request #>
Invoke-WebRequest -Uri $url -Outfile $output

<# Begin Installing Automate with Server Name and Location ID#>

Write-host "====== $output -Server $servername -LocationID $locationID ======"
pause
$SoftwareFullPath=$output

$InstallExitCode = (Start-Process "msiexec.exe" -ArgumentList "/i $($SoftwareFullPath) /quiet /norestart /L*V $($LogFullPath)" -NoNewWindow -Wait -PassThru).ExitCode
If ($InstallExitCode -eq 0) {
    If (!$Silent) {Write-Verbose "The Automate Agent Installer Executed Without Errors"}
} Else {
    Write-Host "Automate Installer Exit Code: $InstallExitCode" -ForegroundColor Red
    Write-Host "Automate Installer Logs: $LogFullPath" -ForegroundColor Red
    Write-Host "The Automate MSI failed. Waiting 15 Seconds..." -ForegroundColor Red
    Start-Sleep -s 15
    Write-Host "Installer will execute twice (KI 12002617)" -ForegroundColor Yellow
    $Date = (get-date -UFormat %Y-%m-%d_%H-%M-%S)
    $LogFullPath = "$env:windir\Temp\Automate_Agent_$Date.log"
    $InstallExitCode = (Start-Process "msiexec.exe" -ArgumentList "/i $($SoftwareFullPath) /quiet /norestart /L*V $($LogFullPath)" -NoNewWindow -Wait -PassThru).ExitCode
    Write-Host "Automate Installer Exit Code: $InstallExitCode" -ForegroundColor Yellow
    Write-Host "Automate Installer Logs: $LogFullPath" -ForegroundColor Yellow
}# End Else
Write-Host "Function Ran"
