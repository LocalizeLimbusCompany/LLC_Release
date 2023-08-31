param(
    [string]$Authorization
)

Remove-Item -Path "Localize" -Recurse
Copy-Item -Path LocalizeLimbusCompany/Localize . -Force -Recurse

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
[IO.File]::WriteAllBytes("test.zip", $response.Content)

# Unzip the file to the current directory
Expand-Archive -Path "test.zip" -DestinationPath "." -Force
	}

Start-Process "lib\LLC_To_Paratranz.exe" -Wait

if (Test-Path -Path "./Error.txt") {
          $error = Get-Content ./Error.txt
          echo "error=$error" >> $env:GITHUB_OUTPUT
          echo "has_error=true" >> $env:GITHUB_OUTPUT
        } else {
          echo "has_error=false" >> $env:GITHUB_OUTPUT
          git config --global user.name 'github-actions[bot]'
          git config --global user.email 'github-actions[bot]@users.noreply.github.com'
          git add Localize/*
          $commitMessage = $(Get-Date -Format "MM-dd")+" AutoUpdate"
          git commit -m $commitMessage
          git push https://github-actions[bot]:${ secrets.GH_TOKEN }@github.com/LocalizeLimbusCompany/LLC_Release
          }
