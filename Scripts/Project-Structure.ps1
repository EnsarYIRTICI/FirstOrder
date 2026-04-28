[CmdletBinding()]
param(
    # Proje kök dizini (vermezsen script otomatik bulur)
    [string]$BaseDir,

    # Hariç tutulacak klasörler
    [string[]]$ExcludeDirs = @(
        ".git",
        "node_modules",
        "bin",
        "obj",
        ".vs",
        ".idea",
        ".vscode",
        "dist"
    )
)

Write-Host "== Proje Yapisi Uretimi Basliyor ==" -ForegroundColor Cyan

# --- BaseDir otomatik belirleme ---
if (-not $BaseDir) {
    $scriptDir = $PSScriptRoot
    if ((Split-Path $scriptDir -Leaf) -in @("Scripts", "scripts")) {
        # Scripts klasorundeyse bir ustu proje kok klasoru
        $BaseDir = Split-Path $scriptDir -Parent
    }
    else {
        # Degilse script'in oldugu klasor proje kok klasoru
        $BaseDir = $scriptDir
    }
}

$BaseDir     = (Resolve-Path $BaseDir).Path
$projectName = Split-Path $BaseDir -Leaf
$outFile     = Join-Path $BaseDir "PROJECT_STRUCTURE.md"

Write-Host "Kok dizin : $BaseDir" -ForegroundColor DarkGray
Write-Host "Cikti     : $outFile" -ForegroundColor DarkGray

# Dosyayi tamamen sifirla
"" | Set-Content -Path $outFile -Encoding UTF8

# Basit yazma helper'i
function Add-Line {
    param([string]$Line)
    $Line | Add-Content -Path $outFile -Encoding UTF8
}

# --- HEADER ---
Add-Line "# $projectName - Proje Dosya Yapisi"
Add-Line ""
Add-Line "Bu dosya projedeki tum dosya ve klasorleri hiyerarsik olarak gosterir."
Add-Line ""
Add-Line "## Proje Kok Dizini"
Add-Line ""

# --- Agac yazan fonksiyon ---
function Write-Tree {
    param(
        [string]$Path,
        [string]$Prefix
    )

    $children = Get-ChildItem -LiteralPath $Path -Force |
        Sort-Object -Property @{ Expression = "PSIsContainer"; Descending = $true }, Name

    $count = $children.Count
    if ($count -eq 0) { return }

    for ($i = 0; $i -lt $count; $i++) {
        $item      = $children[$i]
        $isLast    = ($i -eq $count - 1)
        $connector = if ($isLast) { "└──" } else { "├──" }
        $newPrefix = if ($isLast) { "$Prefix    " } else { "$Prefix│   " }

        if ($item.PSIsContainer) {
            if ($ExcludeDirs -contains $item.Name) { continue }

            Add-Line "$Prefix$connector $($item.Name)/"
            Write-Tree -Path $item.FullName -Prefix $newPrefix
        }
        else {
            Add-Line "$Prefix$connector $($item.Name)"
        }
    }
}

# Agaci olustur
Write-Tree -Path $BaseDir -Prefix ""

Add-Line ""
Add-Line "## Toplam Dosya Sayisi"
Add-Line ""

$allFiles = Get-ChildItem -Path $BaseDir -Recurse -File -Force

$scriptExtensions = @(
    ".ps1", ".psm1", ".psd1",
    ".sh", ".bash", ".zsh",
    ".cmd", ".bat",
    ".ts", ".tsx", ".js", ".jsx",
    ".py", ".rb", ".go",
    ".cs", ".java", ".fs",
    ".rs", ".php"
)

$scriptCount = ($allFiles | Where-Object {
    $scriptExtensions -contains $_.Extension.ToLower()
} | Measure-Object).Count

$configExts = @(".json", ".yml", ".yaml", ".toml", ".env", ".config")

$configCount = ($allFiles | Where-Object {
    $ext  = $_.Extension.ToLower()
    $name = $_.Name.ToLower()
    ($configExts -contains $ext) -or
    $name -like ".env*" -or
    $name -in @(
        "dockerfile",
        "docker-compose.yml",
        ".gitignore",
        ".dockerignore",
        "tsconfig.json",
        "package.json",
        "package-lock.json"
    )
} | Measure-Object).Count

Add-Line "- Script Dosyalari: $scriptCount"
Add-Line "- Konfigurasyon Dosyalari: $configCount"
Add-Line ""
Add-Line "---"
Add-Line ""

$now = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Add-Line "Bu dosya 'Generate-ProjectStructure.ps1' scripti ile otomatik olusturulmustur."
Add-Line "Son guncelleme: $now"

Write-Host "PROJECT_STRUCTURE.md olusturuldu!" -ForegroundColor Green
Write-Host "Script dosyalari    : $scriptCount" -ForegroundColor DarkGray
Write-Host "Konfigurasyon sayisi: $configCount" -ForegroundColor DarkGray
