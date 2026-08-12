@echo off
title Download Ulang Logo
cd /d "%~dp0"

if not exist "assets\logos" (
    echo Membuat folder assets\logos ...
    mkdir "assets\logos"
)

echo ============================================
echo   MULAI DOWNLOAD LOGO DARI jsDelivr CDN
echo ============================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$names = @('adobe','adobeillustrator','adobephotoshop','adobepremierepro','amazon','amazonprimevideo','amongus','brawlstars','callofduty','candycrushsaga','canva','clashofclans','clashroyale','dana','disneyplus','flip','garena','hoyoverse','hulu','indihome','indosatooredoo','iqiyi','jenius','joox','lazada','linkedin','microsoftexcel','microsoftoffice','microsoftonedrive','microsoftpowerpoint','microsoftword','midjourney','minecraft','mondaydotcom','nintendoswitch','openai','ovo','peacock','runway','skype','slack','smartfren','stabilityai','telkomsel','tokopedia','vidio','viu','xbox','xl'); ^
$ok=0; $fail=0; $i=0; ^
foreach ($n in $names) { ^
  $i++; ^
  $url = 'https://cdn.jsdelivr.net/npm/simple-icons@latest/icons/' + $n + '.svg'; ^
  $out = 'assets\logos\' + $n + '.svg'; ^
  Write-Host ('[' + $i + '/' + $names.Count + '] ' + $n + ' ... ') -NoNewline; ^
  try { ^
    Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -TimeoutSec 20; ^
    $size = (Get-Item $out).Length; ^
    if ($size -lt 50) { Write-Host ('GAGAL (file kosong)') -ForegroundColor Red; $fail++ } ^
    else { Write-Host ('OK (' + $size + ' bytes)') -ForegroundColor Green; $ok++ } ^
  } catch { ^
    Write-Host ('GAGAL: ' + $_.Exception.Message) -ForegroundColor Red; ^
    $fail++ ^
  } ^
}; ^
Write-Host ''; ^
Write-Host ('Selesai. Berhasil: ' + $ok + ', Gagal: ' + $fail) -ForegroundColor Cyan"

echo.
echo ============================================
echo   SELESAI. Cek pesan di atas.
echo ============================================
echo.
pause
