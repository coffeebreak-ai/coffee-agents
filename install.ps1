param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$Uninstall = $false,
    [string]$Skill = ""
)

$ErrorActionPreference = 'Stop'

$Repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$Src = Join-Path $Repo 'opencode'

if ($env:OPENCODE_CONFIG_DIR) {
    $Target = $env:OPENCODE_CONFIG_DIR
} elseif ($env:XDG_CONFIG_HOME) {
    $Target = Join-Path $env:XDG_CONFIG_HOME 'opencode'
} else {
    $Target = Join-Path $env:USERPROFILE '.config\opencode'
}

$Stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$Backup = Join-Path $Target ".coffee-backup\$Stamp"
$CreatedList = Join-Path $Backup 'created.txt'
$Begin = '<!-- coffee:begin -->'
$End = '<!-- coffee:end -->'

function Write-Info($text) { Write-Host $text }

function Confirm-Step($text) {
    if ($Force) { return }
    if (-not [Environment]::UserInteractive) { return }
    $answer = Read-Host "$text [y/N]"
    if ($answer -notin @('y', 'Y')) {
        Write-Info 'отменено'
        exit 1
    }
}

function Init-Backup {
    if ($DryRun) { return }
    if (-not (Test-Path -LiteralPath $Backup)) {
        New-Item -ItemType Directory -Path $Backup -Force | Out-Null
    }
    Set-Content -LiteralPath $CreatedList -Value '' -NoNewline
}

function Add-Created($relative) {
    if ($DryRun) { return }
    Add-Content -LiteralPath $CreatedList -Value "$relative`n" -NoNewline
}

function Backup-Path($relative) {
    $path = Join-Path $Target $relative
    if ($DryRun) { return }
    if (-not (Test-Path -LiteralPath $path)) {
        Add-Created $relative
        return
    }
    $dest = Join-Path $Backup $relative
    $parent = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }
    Copy-Item -LiteralPath $path -Destination $dest -Recurse -Force
}

function Install-Agents {
    foreach ($file in Get-ChildItem -Path (Join-Path $Src 'agents') -Filter 'coffee-*.md' -File) {
        $rel = "agents/$($file.Name)"
        Backup-Path $rel
        Write-Info "install $rel"
        if ($DryRun) { continue }
        $dir = Join-Path $Target 'agents'
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
        Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $Target $rel) -Force
    }
}

function Install-Skills {
    foreach ($dir in Get-ChildItem -Path (Join-Path $Src 'skills') -Filter 'coffee-*' -Directory) {
        $rel = "skills/$($dir.Name)"
        Backup-Path $rel
        Write-Info "install $rel"
        if ($DryRun) { continue }
        $dest = Join-Path $Target $rel
        if (Test-Path -LiteralPath $dest) {
            Remove-Item -LiteralPath $dest -Recurse -Force
        }
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Copy-Item -Path (Join-Path $dir.FullName '*') -Destination $dest -Recurse -Force
    }
}

function Write-Block($body) {
    "$Begin`n$body`n$End`n"
}

function Install-Rules {
    $src = Join-Path $Src 'coffee-AGENTS.md'
    $dst = Join-Path $Target 'AGENTS.md'
    $body = Get-Content -LiteralPath $src -Raw
    $block = Write-Block $body

    Backup-Path 'AGENTS.md'

    if (-not (Test-Path -LiteralPath $dst)) {
        Write-Info 'create AGENTS.md'
        if (-not $DryRun) { Set-Content -LiteralPath $dst -Value $block -NoNewline }
        return
    }

    $current = Get-Content -LiteralPath $dst -Raw
    if ($current.Contains($Begin)) {
        Write-Info 'replace coffee block in AGENTS.md'
        if (-not $DryRun) {
            $updated = [regex]::Replace($current, '(?s)<!-- coffee:begin -->.*?<!-- coffee:end -->', $block.TrimEnd("`n"))
            Set-Content -LiteralPath $dst -Value $updated -NoNewline
        }
        return
    }

    $normalizedCurrent = (($current -split "`n") | Where-Object { $_ -notmatch '^# ' }) -join ''
    $normalizedCurrent = $normalizedCurrent -replace '\s', ''
    $normalizedBody = (($body -split "`n") | Where-Object { $_ -notmatch '^# ' }) -join ''
    $normalizedBody = $normalizedBody -replace '\s', ''

    if ($normalizedCurrent -eq $normalizedBody) {
        Write-Info 'rewrite own AGENTS.md as coffee block'
        if (-not $DryRun) { Set-Content -LiteralPath $dst -Value $block -NoNewline }
        return
    }

    Write-Info 'append coffee block to AGENTS.md'
    if (-not $DryRun) { Add-Content -LiteralPath $dst -Value "`n$block" -NoNewline }
}

function Test-Install {
    $bad = $false

    foreach ($dir in Get-ChildItem -Path (Join-Path $Src 'skills') -Filter 'coffee-*' -Directory) {
        if (-not (Test-Path -LiteralPath (Join-Path $dir.FullName 'SKILL.md'))) {
            Write-Info "error: no SKILL.md in $($dir.Name)"
            $bad = $true
        }
    }

    foreach ($file in Get-ChildItem -Path (Join-Path $Src 'agents') -Filter 'coffee-*.md' -File) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        foreach ($match in [regex]::Matches($content, '`(coffee-[a-z0-9-]+)`')) {
            $id = $match.Groups[1].Value
            if (-not (Test-Path -LiteralPath (Join-Path (Join-Path $Src 'skills') $id))) {
                Write-Info "error: agent references missing skill $id"
                $bad = $true
            }
        }
    }

    $pattern = '`(golang-dev|go-layout|gin-swagger|go-calls|python-dev|javascript-dev|typescript-dev|csharp-dev|lua-dev|contract-first|failure-modes|adr|grill-me|qa-blackbox)`'
    if (Select-String -Path (Join-Path $Src '*') -Pattern $pattern -Recurse -Quiet) {
        Write-Info 'error: found reference to unprefixed skill id'
        $bad = $true
    }

    if ($bad) { exit 1 }

    $agents = (Get-ChildItem -Path (Join-Path $Src 'agents') -Filter 'coffee-*.md' -File).Count
    $skills = (Get-ChildItem -Path (Join-Path $Src 'skills') -Filter 'coffee-*' -Directory).Count
    Write-Info "ok: $agents agents, $skills skills"
}

function Install-External-Skill {
    param($Source)
    $skill = $Source
    if ($Source -like '*@*') { $skill = ($Source -split '@')[-1] }
    if ($skill -eq $Source) { $skill = ($Source -split '/')[-1] }
    Write-Info "npx -y skills add $Source --skill $skill -g"
    if ($DryRun) { return }
    npx -y skills add $Source --skill $skill -g
}

function Restore-Backup($latest) {
    $createdPath = Join-Path $latest 'created.txt'
    if (Test-Path -LiteralPath $createdPath) {
        Get-Content -LiteralPath $createdPath | Where-Object { $_ } | ForEach-Object {
            $path = Join-Path $Target $_
            if (Test-Path -LiteralPath $path) { Remove-Item -LiteralPath $path -Recurse -Force }
        }
    }
    Get-ChildItem -Path $latest -Recurse -File | Where-Object { $_.Name -ne 'created.txt' } | ForEach-Object {
        $relative = $_.FullName.Substring($latest.FullName.Length).TrimStart('\', '/')
        if ($relative -match '^agents[\\/]coffee-.*\.md$' -or $relative -match '^skills[\\/]coffee-') { return }
        $dest = Join-Path $Target $relative
        $parent = Split-Path -Parent $dest
        if (-not (Test-Path -LiteralPath $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force
    }
}

function Invoke-Uninstall {
    $root = Join-Path $Target '.coffee-backup'
    if (-not (Test-Path -LiteralPath $root)) {
        Write-Info "error: backup not found in $root"
        exit 1
    }
    $latest = Get-ChildItem -Path $root -Directory | Sort-Object Name | Select-Object -Last 1
    if (-not $latest) {
        Write-Info "error: backup not found in $root"
        exit 1
    }
    Confirm-Step "Удалить файлы coffee-* и восстановить $($latest.FullName)?"
    Write-Info 'remove agents/coffee-*.md and skills/coffee-*'
    Write-Info "restore from $($latest.FullName)"
    if ($DryRun) { return }

    Get-ChildItem -Path (Join-Path $Target 'agents') -Filter 'coffee-*.md' -File -ErrorAction SilentlyContinue |
        Remove-Item -Force
    Get-ChildItem -Path (Join-Path $Target 'skills') -Filter 'coffee-*' -Directory -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force
    Restore-Backup $latest
}

Write-Info "source: $Src"
Write-Info "target: $Target"

if ($Skill) {
    Install-External-Skill -Source $Skill
    Write-Info 'done'
    exit 0
}

Test-Install

if ($Uninstall) {
    Invoke-Uninstall
    exit 0
}

Confirm-Step "Установить coffee-* в $Target?"

Init-Backup
Install-Agents
Install-Skills
Install-Rules

Write-Info 'done'
