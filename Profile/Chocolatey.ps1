function New-ChocoPackage {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ExePath,

        [Parameter(Mandatory = $true)]
        [string]$PackageName,

        [Parameter(Mandatory = $true)]
        [string]$Version,

        [string]$NexusUrl = "http://localhost:8081/repository/chocolatey-hosted/",
        [switch]$Push
    )

    # 1. Dosya Yolu
    $baseDir = Join-Path $PWD $PackageName
    $toolsDir = Join-Path $baseDir "tools"

    # 2. Paket yapısını oluştur
    if (-not (Test-Path $baseDir)) {
        Write-Host "🧱 'choco new' ile temel yapı oluşturuluyor..."
        choco new $PackageName --force
    }

    # 3. EXE dosyasını tools klasörüne taşı
    $exeName = Split-Path $ExePath -Leaf
    Copy-Item $ExePath -Destination "$toolsDir\$exeName" -Force
    Write-Host "📦 EXE dosyası eklendi: $exeName"

    # 4. chocolateyinstall.ps1 dosyasını güncelle
    $installScript = @"
`$ErrorActionPreference = 'Stop'
`$toolsDir = `"\$(Split-Path -parent `$MyInvocation.MyCommand.Definition)`"
`$exePath = Join-Path `$toolsDir '$exeName'
Start-Process -FilePath `$exePath -ArgumentList '/S' -Wait -NoNewWindow
"@
    Set-Content -Path "$toolsDir\chocolateyinstall.ps1" -Value $installScript -Encoding UTF8

    # 5. .nuspec dosyasını güncelle
    $nuspecPath = Join-Path $baseDir "$PackageName.nuspec"
    $nuspecXml = [xml](Get-Content $nuspecPath)

    $nuspecXml.package.metadata.version = $Version
    $nuspecXml.package.metadata.title = "$PackageName (Install)"
    $nuspecXml.package.metadata.authors = "ensar"
    $nuspecXml.package.metadata.projectUrl = "https://example.com"
    $nuspecXml.package.metadata.description = "Auto-packaged $PackageName via script"
    $nuspecXml.package.metadata.tags = $PackageName

    $nuspecXml.Save($nuspecPath)

    # 6. Paketleme
    Push-Location $baseDir
    Write-Host "📦 .nupkg paketi oluşturuluyor..."
    choco pack | Out-Host
    Pop-Location

    # 7. Nexus’a push
    if ($Push) {
        $nupkg = "$baseDir\$PackageName.$Version.nupkg"
        Write-Host "🚀 Nexus'a push ediliyor..."
        choco push $nupkg --source=$NexusUrl --api-key=anykey
    }

    Write-Host "`n✅ Paketleme işlemi tamamlandı: $PackageName $Version"
}
