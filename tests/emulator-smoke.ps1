param(
  [Parameter(Mandatory=$true)][string]$AdbPath,
  [Parameter(Mandatory=$true)][string]$ApkPath,
  [Parameter(Mandatory=$true)][string]$OutputDirectory,
  [ValidatePattern('^emulator-[0-9]+$')][string]$Serial='emulator-5570',
  [switch]$AlreadyInstalled
)
$ErrorActionPreference='Stop'
$AdbPath=(Resolve-Path -LiteralPath $AdbPath).Path
$ApkPath=(Resolve-Path -LiteralPath $ApkPath).Path
$OutputDirectory=[IO.Path]::GetFullPath($OutputDirectory)
if(Test-Path -LiteralPath $OutputDirectory){throw 'Select a new evidence directory.'}
New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
function Emu([string[]]$Arguments) {
  $qemu=& $AdbPath -s $Serial shell getprop ro.kernel.qemu
  if($LASTEXITCODE -ne 0 -or "$qemu".Trim() -ne '1'){throw 'Refusing actions on an unverified emulator.'}
  $result=& $AdbPath -s $Serial @Arguments
  if($LASTEXITCODE -ne 0){throw "Emulator action failed: $($Arguments[0])"}
  return $result
}
function Snapshot([string]$Name) {
  Emu @('shell','uiautomator','dump','/sdcard/adscroll-smoke.xml') | Out-Null
  $path=Join-Path $OutputDirectory "$Name.xml"
  Emu @('pull','/sdcard/adscroll-smoke.xml',$path) | Out-Null
  return [xml](Get-Content -LiteralPath $path -Raw)
}
function Expect([string]$Name,[string]$Text) {
  $ui=Snapshot $Name
  $all=($ui.SelectNodes('//node') | ForEach-Object {$_.text}) -join ' '
  if(!$all.Contains($Text)){throw "Missing expected text at ${Name}: $Text"}
  return $ui
}
function Wait-Rotation([int]$Rotation,[string]$Name) {
  for($attempt=0;$attempt -lt 6;$attempt++) {
    $ui=Snapshot "$Name-$attempt"
    if([int]$ui.hierarchy.rotation -eq $Rotation){return}
    Start-Sleep -Milliseconds 500
  }
  throw 'Rotation did not settle.'
}
$deadline=[DateTime]::UtcNow.AddSeconds(60)
do {
  $boot=& $AdbPath -s $Serial shell getprop sys.boot_completed 2>$null
  if("$boot".Trim() -eq '1'){break}
  Start-Sleep -Seconds 2
}while([DateTime]::UtcNow -lt $deadline)
$originalFont=(Emu @('shell','settings','get','system','font_scale') | Out-String).Trim()
try {
Emu @('shell','settings','put','system','font_scale','1.0') | Out-Null
if(!$AlreadyInstalled){Emu @('install','-r',$ApkPath) | Out-Null}
Emu @('shell','am','force-stop','de.leterel.adscroll') | Out-Null
Emu @('shell','am','start','-W','-n','de.leterel.adscroll/.MainActivity') | Out-Null
$first=Expect '01-first' 'PAUSENKAFFEE'
Expect '02-disclosure' 'FIKTIVE WERBUNG' | Out-Null
$size=(Emu @('shell','wm','size') | Out-String)
if($size -notmatch '(\d+)x(\d+)'){throw 'Unknown emulator display dimensions.'}
$w=[int]$Matches[1]; $h=[int]$Matches[2]
$catalog=@('PAUSENKAFFEE','WOLKENWERK','KNUSPERPOST','LEERLAUF','KURZ RAUS','MORGEN VIELLEICHT')
for($i=1;$i -le 8;$i++) {
  Emu @('shell','input','swipe',"$([int]($w*.5))","$([int]($h*.78))","$([int]($w*.5))","$([int]($h*.24))",'180') | Out-Null
  $ui=Expect "next-$i" $catalog[$i%6]
  if($ui.SelectNodes('//node').Count -gt 60){throw 'Unexpected growth in UI tree.'}
}
Emu @('shell','input','swipe',"$([int]($w*.5))","$([int]($h*.25))","$([int]($w*.5))","$([int]($h*.77))",'180') | Out-Null
Expect 'previous' 'WOLKENWERK' | Out-Null
$rotation=(Emu @('shell','settings','get','system','user_rotation') | Out-String).Trim()
$auto=(Emu @('shell','settings','get','system','accelerometer_rotation') | Out-String).Trim()
try {
  Emu @('shell','settings','put','system','accelerometer_rotation','0') | Out-Null
  Emu @('shell','settings','put','system','user_rotation','1') | Out-Null
  Wait-Rotation 1 'landscape'
  Expect 'rotation-restored-position' 'WOLKENWERK' | Out-Null
  Emu @('shell','input','keyevent','KEYCODE_HOME') | Out-Null
  Emu @('shell','am','start','-W','-n','de.leterel.adscroll/.MainActivity') | Out-Null
  Expect 'resume-restored-position' 'WOLKENWERK' | Out-Null
} finally {
  if($rotation -match '^[0-3]$'){Emu @('shell','settings','put','system','user_rotation',$rotation) | Out-Null}
  if($auto -match '^[01]$'){Emu @('shell','settings','put','system','accelerometer_rotation',$auto) | Out-Null}
}
if($rotation -match '^[0-3]$'){Wait-Rotation ([int]$rotation) 'restored-rotation'}
Emu @('shell','screencap','-p','/sdcard/adscroll-smoke.png') | Out-Null
Emu @('pull','/sdcard/adscroll-smoke.png',(Join-Path $OutputDirectory 'feed.png')) | Out-Null
[ordered]@{passed=$true;emulator=$Serial;inputSha256=(Get-FileHash -LiteralPath $ApkPath).Hash;alreadyInstalled=[bool]$AlreadyInstalled;checks=@('start','fictional disclosure','8 forward swipes with recycled creatives','bounded UI tree','backward swipe','rotation preserves position','background/resume preserves position');realAds=$false} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $OutputDirectory 'result.json')
Write-Output 'PASS: AdScroll emulator gesture, lifecycle and disclosure checks.'
} finally {
  if($originalFont -match '^\d+(\.\d+)?$'){Emu @('shell','settings','put','system','font_scale',$originalFont) | Out-Null}
}
