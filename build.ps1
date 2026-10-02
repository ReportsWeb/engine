param(
    # Released Runtime folder (from Reports-Web-WASM.zip: Reports-Web-WASM/WebAssembly/Runtime/reports.web)
    [Parameter(Mandatory = $true)][string]$Runtime,
    [string]$Version = '1.0.0',
    [switch]$Push
)
# Stage the released runtime into ./context (not committed) and build ghcr.io/reportsweb/engine.
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$ctx = Join-Path $here 'context'
if (Test-Path $ctx) { Remove-Item $ctx -Recurse -Force }
New-Item -ItemType Directory "$ctx\reports.web" | Out-Null
Copy-Item "$Runtime\server" "$ctx\server" -Recurse
Get-ChildItem $Runtime -Force | Where-Object { $_.Name -ne 'server' } | ForEach-Object { Copy-Item $_.FullName "$ctx\reports.web\" -Recurse }
foreach ($f in 'server.mjs', 'pao-reports.wasm', 'NotoSansCJKjp-Regular.otf') {
    if (-not (Test-Path "$ctx\server\$f")) { throw "missing $f in $Runtime\server" }
}
$image = 'ghcr.io/reportsweb/engine'
# docker writes progress to stderr; run it through cmd so PowerShell does not treat that as an error.
cmd /c "docker build --build-arg VERSION=$Version -t ${image}:$Version -t ${image}:latest `"$here`" 2>&1"
if ($LASTEXITCODE) { throw 'docker build failed' }
if ($Push) {
    cmd /c "docker push ${image}:$Version 2>&1"; if ($LASTEXITCODE) { throw 'push failed' }
    cmd /c "docker push ${image}:latest 2>&1"; if ($LASTEXITCODE) { throw 'push failed' }
}
