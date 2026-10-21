param(
    [Parameter(Mandatory = $true)][string]$SdkPath,
    [string]$JavaHome = $env:JAVA_HOME,
    [string]$OutputDirectory,
    [string]$KeyStorePath,
    [string]$SponsorCatalog,
    [switch]$ConfirmSponsorRightsAndContract
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projectRoot = $PSScriptRoot
if ($SponsorCatalog -and !$ConfirmSponsorRightsAndContract) { throw 'Sponsor build requires -ConfirmSponsorRightsAndContract after actual rights and contract review.' }
if ($ConfirmSponsorRightsAndContract -and !$SponsorCatalog) { throw 'Confirmation requires -SponsorCatalog.' }
if (!$OutputDirectory) { $OutputDirectory = Join-Path $projectRoot 'build\outputs' }
if (!$KeyStorePath) { $KeyStorePath = Join-Path $projectRoot 'build\debug.keystore' }
if (!$JavaHome) { $JavaHome = Split-Path (Split-Path (Get-Command javac).Source) }
$OutputDirectory = [System.IO.Path]::GetFullPath($OutputDirectory)
$KeyStorePath = [System.IO.Path]::GetFullPath($KeyStorePath)
$sdk = (Resolve-Path -LiteralPath $SdkPath).Path
$javaBin = Join-Path $JavaHome 'bin'
$buildTools = Join-Path $sdk 'build-tools\36.0.0'
$androidJar = Join-Path $sdk 'platforms\android-36\android.jar'
$build = Join-Path $PSScriptRoot 'build'
if ($SponsorCatalog) { $build = Join-Path $build 'sponsors' }
$main = Join-Path $PSScriptRoot 'app\src\main'
foreach ($required in @($androidJar,(Join-Path $buildTools 'aapt2.exe'),(Join-Path $javaBin 'javac.exe'))) {
    if (!(Test-Path -LiteralPath $required)) { throw "Required build tool missing: $required" }
}
foreach ($part in @('classes','test-classes','generated','dex')) {
    $target = [System.IO.Path]::GetFullPath((Join-Path $build $part))
    if (!$target.StartsWith([System.IO.Path]::GetFullPath($build) + [System.IO.Path]::DirectorySeparatorChar)) { throw 'Invalid build cleanup path' }
    if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
}
foreach ($dir in @($build,$OutputDirectory,(Join-Path $build 'classes'),(Join-Path $build 'test-classes'),(Join-Path $build 'generated'),(Join-Path $build 'dex'),(Split-Path $KeyStorePath))) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
}
Copy-Item -LiteralPath $androidJar -Destination (Join-Path $build 'android.jar') -Force
$androidJar = Join-Path $build 'android.jar'
function Run-Checked([string]$File, [string[]]$Arguments) {
    & $File @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$File failed with exit code $LASTEXITCODE" }
}
$manifest = Join-Path $main 'AndroidManifest.xml'
$catalogSource = $null
if ($SponsorCatalog) {
    $catalogOutput = Join-Path $build ('catalog-' + [guid]::NewGuid().ToString('N'))
    Run-Checked (Get-Command node).Source @((Join-Path $projectRoot 'tools\generate-catalog.mjs'),(Resolve-Path -LiteralPath $SponsorCatalog).Path,$catalogOutput,'--sponsor','--confirm-rights-and-contract')
    $catalogSource = Join-Path $catalogOutput 'Catalog.java'
    $manifest = Join-Path $build 'AndroidManifest.xml'
    $manifestText = [System.IO.File]::ReadAllText((Join-Path $main 'AndroidManifest.xml'))
    $manifestText = $manifestText.Replace('package="de.leterel.adscroll"','package="de.leterel.adscroll.sponsors"').Replace('android:label="AdScroll Demo"','android:label="AdScroll Sponsoren"').Replace('android:name=".MainActivity"','android:name="de.leterel.adscroll.MainActivity"')
    [System.IO.File]::WriteAllText($manifest,$manifestText,[System.Text.UTF8Encoding]::new($false))
}
Run-Checked (Join-Path $buildTools 'aapt2.exe') @('compile','--dir',(Join-Path $main 'res'),'-o',(Join-Path $build 'resources.zip'))
Run-Checked (Join-Path $buildTools 'aapt2.exe') @('link','-o',(Join-Path $build 'unsigned.apk'),'--manifest',$manifest,'-I',$androidJar,'--java',(Join-Path $build 'generated'),'--min-sdk-version','26','--target-sdk-version','36',(Join-Path $build 'resources.zip'))
$sources = @(Get-ChildItem -LiteralPath (Join-Path $main 'java') -Recurse -Filter '*.java' | ForEach-Object FullName)
if ($catalogSource) { $sources = @($sources | Where-Object { [System.IO.Path]::GetFileName($_) -ne 'Catalog.java' }); $sources += $catalogSource }
$sources += @(Get-ChildItem -LiteralPath (Join-Path $build 'generated') -Recurse -Filter '*.java' | ForEach-Object FullName)
Run-Checked (Join-Path $javaBin 'javac.exe') (@('-encoding','UTF-8','--release','8','-classpath',$androidJar,'-d',(Join-Path $build 'classes')) + $sources)
Run-Checked (Join-Path $javaBin 'jar.exe') @('--create','--file',(Join-Path $build 'classes.jar'),'-C',(Join-Path $build 'classes'),'.')
Run-Checked (Join-Path $javaBin 'java.exe') @('-cp',(Join-Path $buildTools 'lib\d8.jar'),'com.android.tools.r8.D8','--release','--min-api','26','--lib',$androidJar,'--output',(Join-Path $build 'dex'),(Join-Path $build 'classes.jar'))
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open((Join-Path $build 'unsigned.apk'), [System.IO.Compression.ZipArchiveMode]::Update)
try {
    foreach ($dexFile in (Get-ChildItem -LiteralPath (Join-Path $build 'dex') -Filter '*.dex')) {
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($archive, $dexFile.FullName, $dexFile.Name, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    }
} finally { $archive.Dispose() }
Run-Checked (Join-Path $buildTools 'zipalign.exe') @('-f','-p','4',(Join-Path $build 'unsigned.apk'),(Join-Path $build 'aligned.apk'))
if (!(Test-Path -LiteralPath $KeyStorePath)) {
    Run-Checked (Join-Path $javaBin 'keytool.exe') @('-genkeypair','-keystore',$KeyStorePath,'-storepass','android','-keypass','android','-alias','androiddebugkey','-dname','CN=AdScroll Development,O=Leterel,C=DE','-keyalg','RSA','-keysize','2048','-validity','10000','-noprompt')
}
$apk = Join-Path $OutputDirectory 'adscroll-0.1.0.apk'
if ($SponsorCatalog) { $apk = Join-Path $OutputDirectory 'adscroll-sponsors-0.1.0.apk' }
Run-Checked (Join-Path $javaBin 'java.exe') @('-jar',(Join-Path $buildTools 'lib\apksigner.jar'),'sign','--ks',$KeyStorePath,'--ks-pass','pass:android','--key-pass','pass:android','--ks-key-alias','androiddebugkey','--out',$apk,(Join-Path $build 'aligned.apk'))
Run-Checked (Join-Path $javaBin 'java.exe') @('-jar',(Join-Path $buildTools 'lib\apksigner.jar'),'verify','--verbose',$apk)
Run-Checked (Join-Path $buildTools 'zipalign.exe') @('-c','-v','4',$apk)
Get-FileHash -LiteralPath $apk -Algorithm SHA256 | Format-List
Write-Output "Built APK: $apk"
