param(
    [string]$Authorization,
    [string]$ServerAuthorization
)
Set-Location "LocalizeLimbusCompany/Localize"

$ErrorFile = "./Error.txt"
if ((Test-Path -Path $ErrorFile)) {
Remove-Item $ErrorFile
	}
else {
$url = "https://paratranz.cn/api/projects/6860/artifacts/download"
$headers = @{
    "Authorization" = "$Authorization"
    "accept" = "*/*"
	}
$response = Invoke-WebRequest -Uri $url -Headers $headers -Method Get
[IO.File]::WriteAllBytes("./LocalizeLimbusCompany/Localize/test.zip", $response.Content)

# Unzip the file to the current directory
Expand-Archive -Path "test.zip" -DestinationPath "." -Force
	}

Start-Process "lib/LLC_To_Paratranz.exe" -Wait

if (Test-Path -Path "./Error.txt") {
          $error = Get-Content ./Error.txt
          echo "error=$error" >> $env:GITHUB_OUTPUT
          echo "has_error=true" >> $env:GITHUB_OUTPUT
        } else {
          git config --global user.name 'github-actions[bot]'
          git config --global user.email 'github-actions[bot]@users.noreply.github.com'
          git add .
          $commitMessage = $(Get-Date -Format "MM-dd")+" AutoUpdate"
          git commit -m $commitMessage
          git push https://github-actions[bot]:${ secrets.GH_TOKEN }@github.com/LocalizeLimbusCompany/LLC_Release
          Set-Location "../"
          ./build.ps1 Dev
          $upload_headers = @{
              "Authorization" = "$ServerAuthorization"
          }
          curl -X POST http://45.158.169.136:4512/upload -F "file=@./Release/LimbusLocalize_BIE_Dev.7z" -H "Authorization: $ServerAuthorization"
        }
