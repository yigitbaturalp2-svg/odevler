Add-Type -AssemblyName System.Drawing
$source = 'C:\Users\yigit\.gemini\antigravity\brain\ae264136-0786-416b-8b83-5948c83a7d22\demokrasi_app_logo_1790884855124.jpg'
$img = [System.Drawing.Image]::FromFile($source)

$sizes = @{
    'mipmap-mdpi' = 48
    'mipmap-hdpi' = 72
    'mipmap-xhdpi' = 96
    'mipmap-xxhdpi' = 144
    'mipmap-xxxhdpi' = 192
}

$resBase = 'C:\Users\yigit\.gemini\antigravity\scratch\demokrasi_app\android\app\src\main\res'

foreach ($folder in $sizes.Keys) {
    $dim = $sizes[$folder]
    $destPath = Join-Path (Join-Path $resBase $folder) 'ic_launcher.png'
    $bmp = New-Object System.Drawing.Bitmap $dim, $dim
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.DrawImage($img, 0, 0, $dim, $dim)
    $g.Dispose()
    $bmp.Save($destPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Saved $destPath ($dim x $dim)"
}

# Also save an in-app asset icon
$assetsDir = 'C:\Users\yigit\.gemini\antigravity\scratch\demokrasi_app\assets\icon'
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}
$assetPath = Join-Path $assetsDir 'app_logo.png'
$bmpAsset = New-Object System.Drawing.Bitmap 512, 512
$gAsset = [System.Drawing.Graphics]::FromImage($bmpAsset)
$gAsset.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gAsset.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gAsset.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$gAsset.DrawImage($img, 0, 0, 512, 512)
$gAsset.Dispose()
$bmpAsset.Save($assetPath, [System.Drawing.Imaging.ImageFormat]::Png)
$bmpAsset.Dispose()
Write-Host "Saved $assetPath"

$img.Dispose()
Write-Host "All launcher icons generated successfully!"
