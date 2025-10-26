<#
Helper PowerShell script to add, commit, and push the README.md (or other changes) to a GitHub repo.

USAGE:
  - Open PowerShell in the repository root (d:\32-bit-adder) or run this script from that folder.
  - Run:  .\push_to_github.ps1 -Remote "origin" -Branch "main" -Message "Add README.md"

NOTES & AUTH:
  - This script does NOT store or manage credentials. Use Git Credential Manager (recommended on Windows), the GitHub CLI (`gh auth login`), or set a remote with a personal access token (PAT) if needed.
  - If you don't have a remote named 'origin', set it before running or run the script with the -AddRemote flag and supply the RepoUrl parameter.

#>
param(
    [string]$Remote = "origin",
    [string]$Branch = "main",
    [string]$Message = "Add README.md",
    [switch]$AddRemote,
    [string]$RepoUrl
)

function Run-Git([string]$cmd) {
    Write-Host "git $cmd" -ForegroundColor Cyan
    $proc = Start-Process git -ArgumentList $cmd -NoNewWindow -RedirectStandardOutput -RedirectStandardError -PassThru -Wait
    $out = $proc.StandardOutput.ReadToEnd()
    $err = $proc.StandardError.ReadToEnd()
    if ($out) { Write-Host $out }
    if ($err) { Write-Host $err -ForegroundColor Red }
    return $proc.ExitCode
}

# Ensure we are in repository folder (user should run script from repo root)
Write-Host "Working directory: $(Get-Location)" -ForegroundColor Green

# Optional: add remote if requested
if ($AddRemote) {
    if (-not $RepoUrl) {
        Write-Host "AddRemote specified but RepoUrl not provided. Use -RepoUrl 'https://github.com/username/repo.git'" -ForegroundColor Yellow
        exit 1
    }
    Write-Host "Adding remote '$Remote' -> $RepoUrl" -ForegroundColor Green
    Run-Git "remote add $Remote $RepoUrl"
}

# Basic checks
$rc = Run-Git "status --porcelain"
if ($rc -ne 0) {
    Write-Host "git status failed. Are you in a git repository?" -ForegroundColor Red
    exit $rc
}

# Stage README.md (and any other changed files if you prefer)
Run-Git "add README.md"

# Commit
Run-Git "commit -m \"$Message\"" | Out-Null

# Set branch name locally (optional)
Run-Git "branch -M $Branch"

# Push
$pushCmd = "push $Remote $Branch -u"
$exit = Run-Git $pushCmd
if ($exit -eq 0) {
    Write-Host "Push succeeded." -ForegroundColor Green
} else {
    Write-Host "Push failed. Check remote, authentication, and permissions." -ForegroundColor Red
    Write-Host "Common fixes: set remote URL, run 'gh auth login', or configure Git Credential Manager." -ForegroundColor Yellow
    exit $exit
}
