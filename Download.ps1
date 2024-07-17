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
Invoke-WebRequest -Uri "https://paratranz.cn/api/projects/6860/artifacts" -Headers $headers -Method Post
# 预留时间来生成zip，延迟7500ms
Start-Sleep -m 7500
$response = Invoke-WebRequest -Uri $url -Headers $headers -Method Get
[IO.File]::WriteAllBytes("./LocalizeLimbusCompany/Localize/test.zip", $response.Content)

# Unzip the file to the current directory
Expand-Archive -Path "test.zip" -DestinationPath "." -Force
	}

Start-Process "lib/LLC_Paratranz_Util.exe" -Wait

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
          $Path = "Release"
          $BIE_LLC_Path = "$Path/LimbusLocalize/BepInEx/plugins/LLC"
          New-Item -Path "$BIE_LLC_Path" -Name "Localize" -ItemType "directory" -Force
          Copy-Item -Path Localize/CN $BIE_LLC_Path/Localize -Force -Recurse
          Set-Location "$Path/LimbusLocalize"
	 7z a -t7z "../LimbusLocalize_BIE_Dev.7z" "BepInEx/" -mx=9 -ms
          Set-Location "../"
          $upload_headers = @{
              "Authorization" = "$ServerAuthorization"
          }
          curl -X POST https://api.zeroasso.top/upload -F "file=@./LimbusLocalize_BIE_Dev.7z" -H "Authorization: $ServerAuthorization" --ssl-no-revoke
        }
