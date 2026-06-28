# "Moja Biblioteka" — Complete Project Walkthrough & Verification Commands

This document provides a full guide to the "Moja Biblioteka" Flask Book Catalog codebase and a list of commands to inspect and double-check every aspect of the project (Git history, database, virtual environment, and HTTP endpoints).

---

## 1. Project Directory Structure

```
projekt/
├── app.py                  # Main Flask application
├── init_db.py              # Database initialization & seed script
├── database.db             # SQLite database file (seeded with 9 books)
├── static/
│   └── style.css           # Google Material 3 stylesheet
├── templates/
│   ├── base.html           # Base layout template (Roboto fonts & Material symbols)
│   ├── index.html          # Book catalog index page (Play Books style grid)
│   ├── details.html        # Single book detail page
│   └── add.html            # Add new book form
├── venv/                   # Python virtual environment (gitignored)
├── .gitignore              # Git ignore rules
├── run_checks.ps1          # One-click verification script
└── walkthrough_commands.md # This document
```

---

## 2. Git History & Configuration Verification

### A. View Commit History
```powershell
& "C:\Users\Gigabyte\AppData\Local\GitHubDesktop\app-3.6.1\resources\app\git\cmd\git.exe" log --oneline
```
*Expected Output:*
```
... First Public Version
a8511e7 Overhaul UI to Google-style Material 3 Design
2d1a546 Save all project files and dependencies
2165bd9 Add gunicorn for production deployment
7147f3e Initial commit: Flask book application MVP
```

### B. View Local Git Configuration
```powershell
& "C:\Users\Gigabyte\AppData\Local\GitHubDesktop\app-3.6.1\resources\app\git\cmd\git.exe" config --list --local
```
*Expected Output includes:*
```
user.name=Valerii Diachuk
user.email=dvaleri1@stu.vistula.edu.pl
remote.origin.url=https://github.com/VD77608/projekt.git
```

### C. Verify Clean Working Tree
```powershell
& "C:\Users\Gigabyte\AppData\Local\GitHubDesktop\app-3.6.1\resources\app\git\cmd\git.exe" status
```
*Expected Output:*
```
On branch main
nothing to commit, working tree clean
```

---

## 3. SQLite Database Verification

### A. Verify Table Schema
```powershell
python -c "import sqlite3; conn = sqlite3.connect('database.db'); cursor = conn.execute(\"SELECT sql FROM sqlite_master WHERE type='table' AND name='books'\"); print(cursor.fetchone()[0])"
```
*Expected Output:*
```sql
CREATE TABLE books (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    title       TEXT NOT NULL,
    author      TEXT NOT NULL,
    description TEXT NOT NULL
)
```

### B. Query All Seeded Books
```powershell
$env:PYTHONIOENCODING="utf-8"; python -c "import sqlite3; conn = sqlite3.connect('database.db'); conn.row_factory = sqlite3.Row; [print(f\"{r['id']} | {r['title']} | {r['author']}\") for r in conn.execute('SELECT * FROM books').fetchall()]"
```
*Expected Output:*
```
1 | Wiedźmin: Ostatnie życzenie | Andrzej Sapkowski
2 | Rok 1984 | George Orwell
3 | Podziemny krąg | Chuck Palahniuk
4 | Nowy wspaniały świat | Aldous Huxley
5 | Tako rzecze Zaratustra | Friedrich Nietzsche
6 | Poza dobrem i złem | Friedrich Nietzsche
7 | Świat jako wola i przedstawienie | Arthur Schopenhauer
8 | Aforyzmy o mądrości życia | Arthur Schopenhauer
9 | Boska Komedia: Piekło | Dante Alighieri
```

---

## 4. Dependencies Verification

```powershell
.\venv\Scripts\pip list
```
*Expected Output includes:*
```
Package      Version
------------ -------
blinker      1.9.0
click        8.4.1
Flask        3.1.3
gunicorn     26.0.0
itsdangerous 2.2.0
Jinja2       3.1.6
MarkupSafe   3.0.3
Werkzeug     3.1.8
```

---

## 5. Web Application Endpoints Verification

### Step A: Start the Server
```powershell
$env:PYTHONIOENCODING="utf-8"
Start-Process -NoNewWindow -FilePath ".\venv\Scripts\python.exe" -ArgumentList "app.py"
Start-Sleep -Seconds 2
```

### Step B: Test GET / (Catalog Page)
```powershell
$res = Invoke-WebRequest -Uri "http://127.0.0.1:5000/" -UseBasicParsing
$res.StatusCode                              # Expected: 200
$res.Content.Contains("Katalog Książek")     # Expected: True
```

### Step C: Test GET /book/1 (Book Details)
```powershell
$res = Invoke-WebRequest -Uri "http://127.0.0.1:5000/book/1" -UseBasicParsing
$res.StatusCode                                                # Expected: 200
$res.Content.Contains("Andrzej Sapkowski")                     # Expected: True
```

### Step D: Test GET /book/999 (404 Response)
```powershell
try {
    Invoke-WebRequest -Uri "http://127.0.0.1:5000/book/999" -UseBasicParsing
} catch {
    $_.Exception.Response.StatusCode                           # Expected: NotFound (404)
}
```

### Step E: Test Validation Failure
```powershell
$res = Invoke-WebRequest -Uri "http://127.0.0.1:5000/add" -Method Post -Body @{ title=""; author="X"; description="" } -UseBasicParsing
$res.Content.Contains("Wszystkie pola są wymagane!")           # Expected: True
```

### Step F: Shutdown the Server
```powershell
Get-Process python | Stop-Process -Force
```
