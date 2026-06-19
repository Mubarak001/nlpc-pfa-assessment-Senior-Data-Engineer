# Task 3: PowerShell – Deploy BI Artefact from /Dev to /Test
# Target: Power BI Report Server (PBIRS) REST API v2.0
# Replace <sever_IP_address> with your actual server IP address

$BaseUrl    = "https://<sever_IP_address>/reports/api/v2.0"
$SourcePath = "/Dev/AssetRegister_Dashboard"
$TargetPath = "/Test/AssetRegister_Dashboard"

# Prompt for service account credentials 
$Credential = Get-Credential

# Build request payload
$Body = @{
    Path      = $TargetPath(Test) 
    Overwrite = $true
} | ConvertTo-Json

# Invoke the copy via REST API
$Response = Invoke-RestMethod `
    -Uri         "$BaseUrl/CatalogItems/Model.CopyItem" `
    -Method      POST `
    -Body        $Body `
    -ContentType "application/json" `
    -Credential  $Credential

# Output result
if ($Response) {
    Write-Host "SUCCESS: Artefact promoted to $TargetPath" -ForegroundColor Green
} else {
    Write-Host "FAILED: Check PBIRS server logs for details." -ForegroundColor Red
}

# Notes:
# - For Power BI Service (cloud), replace endpoint with Fabric REST API
#   and use Bearer token auth via Connect-PowerBIServiceAccount
# - Overwrite flag prevents errors if artefact already exists in /Test
# - CopyItem endpoint applies to PBIRS 2019+ (API v2.0)
