param([string]$Maven = 'mvn', [switch]$CheckJsp)
$ErrorActionPreference = 'Stop'
Push-Location $PSScriptRoot
try {
    & $Maven 'package' '-DskipTests'
    if ($LASTEXITCODE -ne 0) { throw 'Java build failed.' }
    if ($CheckJsp) {
        & $Maven '-Pjsp-check' 'dependency:copy-dependencies' '-DincludeScope=test' '-DoutputDirectory=target/jsp-libs'
        if ($LASTEXITCODE -ne 0) { throw 'Could not resolve JSP compiler.' }
        $taskJars = (Get-ChildItem -LiteralPath 'target/jsp-libs' -Filter '*.jar' | ForEach-Object { $_.FullName }) -join ';'
        $taskClasspath = (Join-Path $PSScriptRoot 'target/classes') + ';' + $taskJars
        & java '-cp' $taskClasspath 'org.apache.jasper.JspC' '-uriroot' 'WebContent' '-d' 'target/jsp-compiled' '-compile' '-source' '11' '-target' '11'
        if ($LASTEXITCODE -ne 0) { throw 'JSP compilation failed.' }
    }
    Write-Output (Join-Path $PSScriptRoot 'target/LibMan.war')
} finally { Pop-Location }
