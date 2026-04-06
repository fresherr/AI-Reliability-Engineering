# PowerShell helper to install tools for Windows
# Tries winget first, then bash (Git Bash/WSL); exits with non-zero if neither is available.

try {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host 'winget found: attempting winget installs'
        try {
            winget install --id 'ChrisAnderson.k9s' -e --accept-package-agreements --accept-source-agreements
        } catch {
            Write-Warning 'k9s winget install failed or is not available'
        }
        try {
            winget install --id 'OpenTofu.OpenTofu' -e --accept-package-agreements --accept-source-agreements
        } catch {
            Write-Warning 'OpenTofu winget install failed or is not available'
        }
        exit 0
    }

    if (Get-Command bash -ErrorAction SilentlyContinue) {
        Write-Host 'bash found: running installer scripts inside bash'
        $cmd1 = 'curl -fsSL https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method standalone'
        & bash -lc $cmd1
        if ($LASTEXITCODE -ne 0) {
            $cmd1b = 'wget -qO- https://get.opentofu.org/install-opentofu.sh | sh -s -- --install-method standalone'
            & bash -lc $cmd1b
        }

        $cmd2 = 'curl -sS https://webi.sh/k9s | bash'
        & bash -lc $cmd2
        if ($LASTEXITCODE -ne 0) {
            $cmd2b = 'wget -qO- https://webi.sh/k9s | bash'
            & bash -lc $cmd2b
        }
        exit 0
    }

    Write-Error "No winget or bash detected. Please install winget or Git Bash/WSL and re-run 'make tools'."
    exit 1
} catch {
    Write-Error "Tool installer failed: $_"
    exit 1
}
