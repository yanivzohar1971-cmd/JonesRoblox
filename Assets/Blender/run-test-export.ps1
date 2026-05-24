# Jones Roblox — run Blender headless test export (apple_test.glb)
# Usage (from repo root or anywhere):
#   powershell -ExecutionPolicy Bypass -File Assets\Blender\run-test-export.ps1

$ErrorActionPreference = "Stop"

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$ScriptRel = "Assets\Blender\create_test_asset.py"
$ScriptPath = Join-Path $RepoRoot $ScriptRel

$BlenderExe = $env:BLENDER_EXE
if (-not $BlenderExe -or -not (Test-Path $BlenderExe)) {
    $candidates = @(
        "C:\Program Files\Blender Foundation\Blender 5.1\blender.exe",
        "C:\Program Files\Blender Foundation\Blender 4.2\blender.exe",
        "C:\Program Files\Blender Foundation\Blender 4.1\blender.exe"
    )
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) {
            $BlenderExe = $candidate
            break
        }
    }
}

if (-not $BlenderExe -or -not (Test-Path $BlenderExe)) {
    throw "Blender not found. Set BLENDER_EXE to your blender.exe path."
}

Write-Host "Repo:    $RepoRoot"
Write-Host "Blender: $BlenderExe"
Write-Host "Script:  $ScriptPath"
Write-Host ""

Set-Location $RepoRoot
& $BlenderExe --background --python $ScriptPath

$ExportPath = Join-Path $RepoRoot "Assets\Blender\exports\apple_test.glb"
if (-not (Test-Path $ExportPath)) {
    throw "Export failed - file not found: $ExportPath"
}

Write-Host ""
Write-Host "Success: $ExportPath"
