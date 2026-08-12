@echo off
title Download Logo Tambahan (via Google Favicon)
cd /d "%~dp0"
if not exist "assets\logos" mkdir "assets\logos"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$l=Get-Content -LiteralPath '%~f0';$i=($l|Select-String '^#PS1START#').LineNumber;$c=$l[$i..($l.Count-1)]|Out-String;Invoke-Expression $c"

echo.
pause
exit /b

#PS1START#
$ErrorActionPreference = 'Continue'

$map = [ordered]@{
    'amazonprimevideo' = 'primevideo.com'
    'amongus'          = 'innersloth.com'
    'brawlstars'       = 'brawlstars.com'
    'callofduty'       = 'callofduty.com'
    'candycrushsaga'   = 'king.com'
    'clashofclans'     = 'clashofclans.com'
    'clashroyale'      = 'clashroyale.com'
    'dana'             = 'dana.id'
    'disneyplus'       = 'disneyplus.com'
    'flip'             = 'flip.id'
    'garena'           = 'garena.com'
    'hoyoverse'        = 'hoyoverse.com'
    'indihome'         = 'indihome.co.id'
    'indosatooredoo'   = 'indosatooredoo.com'
    'iqiyi'            = 'iq.com'
    'jenius'           = 'jenius.com'
    'joox'             = 'joox.com'
    'lazada'           = 'lazada.co.id'
    'midjourney'       = 'midjourney.com'
    'mondaydotcom'     = 'monday.com'
    'ovo'              = 'ovo.id'
    'peacock'          = 'peacocktv.com'
    'runway'           = 'runwayml.com'
    'smartfren'        = 'smartfren.com'
    'stabilityai'      = 'stability.ai'
    'telkomsel'        = 'telkomsel.com'
    'tokopedia'        = 'tokopedia.com'
    'vidio'            = 'vidio.com'
    'viu'              = 'viu.com'
    'xl'               = 'xl.co.id'
}

$outDir = 'assets\logos'

Write-Host "============================================"
Write-Host "  DOWNLOAD 24 LOGO YANG TIDAK ADA DI simple-icons"
Write-Host "  Sumber: favicon resmi dari domain tiap brand"
Write-Host "============================================"
Write-Host ""

$ok = 0
$fail = 0
$i = 0
$total = $map.Count

foreach ($key in $map.Keys) {
    $i++
    $domain = $map[$key]
    $url = "https://www.google.com/s2/favicons?domain=$domain&sz=256"
    $out = Join-Path $outDir "$key.png"

    Write-Host "[$i/$total] $key ($domain) ... " -NoNewline

    try {
        Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -TimeoutSec 20
        $size = (Get-Item $out).Length
        if ($size -lt 200) {
            Write-Host "KECIL/KOSONG ($size bytes)" -ForegroundColor Yellow
            $fail++
        } else {
            Write-Host "OK ($size bytes)" -ForegroundColor Green
            $ok++
        }
    } catch {
        Write-Host "GAGAL: $($_.Exception.Message)" -ForegroundColor Red
        $fail++
    }
}

Write-Host ""
Write-Host "Selesai. Berhasil: $ok, Gagal: $fail" -ForegroundColor Cyan
Write-Host "Catatan: hasil berupa .png (favicon resolusi tinggi), bukan .svg." -ForegroundColor Gray
