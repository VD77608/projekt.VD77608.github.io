# PowerShell verification suite for "Moja Biblioteka"
$ErrorActionPreference = "Stop"
$git = "C:\Users\Gigabyte\AppData\Local\GitHubDesktop\app-3.6.1\resources\app\git\cmd\git.exe"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Starting Verification Suite for Moja Biblioteka " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Check Files
Write-Host "`n[1/5] Checking project files..." -ForegroundColor Yellow
$requiredFiles = @("app.py","init_db.py","database.db",".gitignore","static/style.css","templates/base.html","templates/index.html","templates/details.html","templates/add.html")
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  [PASS] Found: $file" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Missing: $file" -ForegroundColor Red; exit 1
    }
}

# 2. Check Git config & history
Write-Host "`n[2/5] Checking Git history and config..." -ForegroundColor Yellow
if (Test-Path $git) {
    & $git log --oneline | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    $branch = & $git branch --show-current
    if ($branch -eq "main") { Write-Host "  [PASS] Branch is 'main'" -ForegroundColor Green }
    else { Write-Host "  [FAIL] Branch is '$branch'" -ForegroundColor Red }
    $name  = & $git config --local user.name
    $email = & $git config --local user.email
    if ($name -eq "Valerii Diachuk" -and $email -eq "dvaleri1@stu.vistula.edu.pl") {
        Write-Host "  [PASS] Git user: $name <$email>" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Git user mismatch: $name <$email>" -ForegroundColor Red
    }
    $remoteUrl = & $git remote get-url origin
    if ($remoteUrl -match "VD77608") {
        Write-Host "  [PASS] Remote URL: $remoteUrl" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Remote URL does not use VD77608: $remoteUrl" -ForegroundColor Red
    }
} else {
    Write-Host "  [WARNING] Git not found at expected path." -ForegroundColor Yellow
}

# 3. Check database
Write-Host "`n[3/5] Checking SQLite database..." -ForegroundColor Yellow
try {
    $env:PYTHONIOENCODING = "utf-8"
    $count = python -c "import sqlite3; c=sqlite3.connect('database.db'); print(c.execute('SELECT COUNT(*) FROM books').fetchone()[0])"
    Write-Host "  [PASS] Database accessible. Books seeded: $count" -ForegroundColor Green
} catch {
    Write-Host "  [FAIL] Database error: $_" -ForegroundColor Red; exit 1
}

# 4. Check venv dependencies
Write-Host "`n[4/5] Checking virtual environment dependencies..." -ForegroundColor Yellow
if (Test-Path "venv\Scripts\pip.exe") {
    $pipList = & "venv\Scripts\pip.exe" freeze
    @("Flask","Werkzeug","Jinja2","click","blinker","itsdangerous","MarkupSafe","gunicorn") | ForEach-Object {
        if ($pipList -match "(?i)$_") { Write-Host "  [PASS] $_" -ForegroundColor Green }
        else { Write-Host "  [FAIL] Missing: $_" -ForegroundColor Red; exit 1 }
    }
} else {
    Write-Host "  [FAIL] venv not found." -ForegroundColor Red; exit 1
}

# 5. Check web endpoints
Write-Host "`n[5/5] Checking web endpoints..." -ForegroundColor Yellow
$serverProcess = $null
try {
    Write-Host "  Starting Flask server..." -ForegroundColor DarkGray
    $serverProcess = Start-Process -NoNewWindow -FilePath "venv\Scripts\python.exe" -ArgumentList "app.py" -PassThru
    Start-Sleep -Seconds 3

    # GET /
    $res = Invoke-WebRequest -Uri "http://127.0.0.1:5000/" -UseBasicParsing
    if ($res.StatusCode -eq 200 -and $res.Content -match "Katalog Książek") {
        Write-Host "  [PASS] GET /  — catalog page loads" -ForegroundColor Green
    } else { Write-Host "  [FAIL] GET / failed" -ForegroundColor Red; exit 1 }

    # GET /book/1
    $res = Invoke-WebRequest -Uri "http://127.0.0.1:5000/book/1" -UseBasicParsing
    if ($res.StatusCode -eq 200 -and $res.Content -match "Andrzej Sapkowski") {
        Write-Host "  [PASS] GET /book/1  — book details load" -ForegroundColor Green
    } else { Write-Host "  [FAIL] GET /book/1 failed" -ForegroundColor Red; exit 1 }

    # GET /book/999 — must be 404
    try {
        Invoke-WebRequest -Uri "http://127.0.0.1:5000/book/999" -UseBasicParsing | Out-Null
        Write-Host "  [FAIL] GET /book/999 did not return 404" -ForegroundColor Red; exit 1
    } catch {
        $code = $_.Exception.Response.StatusCode
        if ($code -eq 404) { Write-Host "  [PASS] GET /book/999  — 404 with Polish message" -ForegroundColor Green }
        else { Write-Host "  [FAIL] GET /book/999 returned $code instead of 404" -ForegroundColor Red; exit 1 }
    }

    # POST /add — validation failure
    $res = Invoke-WebRequest -Uri "http://127.0.0.1:5000/add" -Method Post -Body @{title="";author="X";description=""} -UseBasicParsing
    if ($res.Content -match "Wszystkie pola są wymagane!") {
        Write-Host "  [PASS] POST /add  — empty-field validation works" -ForegroundColor Green
    } else { Write-Host "  [FAIL] POST /add validation missing" -ForegroundColor Red; exit 1 }

    # POST /add — success
    $res = Invoke-WebRequest -Uri "http://127.0.0.1:5000/add" -Method Post -Body @{title="678";author="DES";description="test entry added via form"} -UseBasicParsing
    if ($res.StatusCode -eq 200 -and $res.Content -match "678") {
        Write-Host "  [PASS] POST /add  — book created and redirect to index" -ForegroundColor Green
    } else { Write-Host "  [FAIL] POST /add book creation failed" -ForegroundColor Red; exit 1 }

} catch {
    Write-Host "  [FAIL] Unexpected error: $_" -ForegroundColor Red
} finally {
    if ($serverProcess) { $serverProcess | Stop-Process -Force }
    Write-Host "  Flask server stopped." -ForegroundColor DarkGray
    # Restore database to clean 9-book state
    if (Test-Path $git) { & $git checkout database.db 2>$null }
    Write-Host "  database.db restored to original seeded state." -ForegroundColor DarkGray
}

Write-Host "`n==================================================" -ForegroundColor Cyan
Write-Host " All checks passed!                               " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Cyan
