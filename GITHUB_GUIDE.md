# 📦 PANDUAN UPLOAD KE GITHUB - Step by Step

Panduan lengkap dari NOL untuk yang belum pernah pakai Git.

---

## STEP 1: Install Git (Kalau Belum Ada)

```bash
# Check apakah Git sudah installed
git --version

# Kalau belum ada, install:
pkg install git
```

---

## STEP 2: Konfigurasi Git (Pertama Kali Aja)

```bash
# Set nama kamu
git config --global user.name "Nama Kamu"

# Set email GitHub kamu
git config --global user.email "email@kamu.com"

# Check konfigurasi
git config --list
```

---

## STEP 3: Buat Repository di GitHub

### A. Buka GitHub (di browser)
1. Buka https://github.com
2. Login ke akun GitHub kamu
3. Klik tombol **"+"** (pojok kanan atas)
4. Pilih **"New repository"**

### B. Isi Form Repository
```
Repository name: vpn-multi-manager
Description: Docker-based VPN Multi-Profile Management System
Public/Private: Pilih "Public" (biar bisa install via curl)
☐ Add README (JANGAN DICENTANG - kita sudah punya)
☐ Add .gitignore (JANGAN DICENTANG - sudah ada)
☐ Choose license: MIT License (OPSIONAL)
```

### C. Klik "Create repository"

### D. Copy URL Repository
Setelah dibuat, kamu akan lihat halaman dengan 2 pilihan URL:
- **HTTPS**: https://github.com/username/vpn-multi-manager.git
- **SSH**: git@github.com:username/vpn-multi-manager.git

**COPY URL HTTPS** (lebih mudah untuk pemula)

---

## STEP 4: Upload Code ke GitHub

### A. Masuk ke Folder Project

```bash
cd /data/data/com.termux/files/home/ai/vpn
```

### B. Initialize Git Repository

```bash
# Buat git repository di folder ini
git init

# Output:
# Initialized empty Git repository in /data/data/com.termux/files/home/ai/vpn/.git/
```

### C. Add Semua File

```bash
# Add semua file ke staging
git add .

# Check file yang akan di-commit
git status
```

**Output contoh:**
```
On branch main
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

        new file:   .env.example
        new file:   .gitignore
        new file:   BACKUP_GUIDE.md
        new file:   INSTALL.md
        new file:   README.md
        ... (banyak file lainnya)
```

### D. Commit Files

```bash
# Commit dengan message
git commit -m "Initial commit: VPN Multi-Profile Manager v1.0"
```

**Output:**
```
[main (root-commit) abc1234] Initial commit: VPN Multi-Profile Manager v1.0
 50 files changed, 5000 insertions(+)
 create mode 100644 .env.example
 create mode 100644 .gitignore
 ... (daftar file)
```

### E. Rename Branch ke Main (Kalau Perlu)

```bash
# GitHub sekarang pakai "main" bukan "master"
git branch -M main
```

### F. Connect ke GitHub Repository

```bash
# Ganti URL dengan URL repository kamu!
git remote add origin https://github.com/USERNAME-KAMU/vpn-multi-manager.git

# Check remote
git remote -v
```

**Output:**
```
origin  https://github.com/USERNAME-KAMU/vpn-multi-manager.git (fetch)
origin  https://github.com/USERNAME-KAMU/vpn-multi-manager.git (push)
```

### G. Push ke GitHub

```bash
# Push semua code ke GitHub
git push -u origin main
```

**GitHub akan minta login:**
```
Username for 'https://github.com': USERNAME-KAMU
Password for 'https://USERNAME-KAMU@github.com':
```

**⚠️ IMPORTANT:** GitHub tidak pakai password lagi! Harus pakai **Personal Access Token (PAT)**

---

## STEP 5: Buat Personal Access Token (PAT)

### A. Buka GitHub Settings
1. GitHub → klik **foto profile** (pojok kanan atas)
2. Pilih **"Settings"**
3. Scroll ke bawah, pilih **"Developer settings"**
4. Pilih **"Personal access tokens"**
5. Pilih **"Tokens (classic)"**
6. Klik **"Generate new token"** → **"Generate new token (classic)"**

### B. Konfigurasi Token
```
Note: VPN Multi-Profile Manager (deskripsi token)
Expiration: No expiration (atau pilih 90 days)

Select scopes (centang yang ini):
☑ repo (Full control of private repositories)
  ☑ repo:status
  ☑ repo_deployment
  ☑ public_repo
  ☑ repo:invite
```

### C. Generate Token
1. Klik **"Generate token"** (paling bawah)
2. **COPY TOKEN** yang muncul (format: ghp_xxxxxxxxxxxxxxxxxxxx)
3. **SIMPAN BAIK-BAIK** (tidak bisa dilihat lagi!)

### D. Gunakan Token sebagai Password

```bash
# Push lagi dengan token
git push -u origin main

# Masukkan:
Username: USERNAME-KAMU
Password: ghp_xxxxxxxxxxxxxxxxxxxx (paste token kamu)
```

**Output sukses:**
```
Enumerating objects: 100, done.
Counting objects: 100% (100/100), done.
Compressing objects: 100% (80/80), done.
Writing objects: 100% (100/100), 50.00 KiB | 5.00 MiB/s, done.
Total 100 (delta 20), reused 0 (delta 0)
To https://github.com/USERNAME-KAMU/vpn-multi-manager.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

## STEP 6: Update install.sh dengan GitHub URL

```bash
# Edit install.sh
nano /data/data/com.termux/files/home/ai/vpn/install.sh
```

**Cari line 18-19, ganti dengan URL kamu:**

```bash
# BEFORE:
REPO_URL="https://github.com/yourusername/vpn-multi"
RAW_URL="https://raw.githubusercontent.com/yourusername/vpn-multi/main"

# AFTER (ganti dengan username kamu!):
REPO_URL="https://github.com/USERNAME-KAMU/vpn-multi-manager"
RAW_URL="https://raw.githubusercontent.com/USERNAME-KAMU/vpn-multi-manager/main"
```

**Save:** Ctrl+X → Y → Enter

**Commit & push perubahan:**

```bash
git add install.sh
git commit -m "Update GitHub URL in install.sh"
git push
```

---

## STEP 7: Verifikasi Upload Sukses

### A. Buka GitHub di Browser
```
https://github.com/USERNAME-KAMU/vpn-multi-manager
```

Kamu harus lihat:
- ✅ Semua file sudah ada
- ✅ README.md tampil di halaman utama
- ✅ .gitignore file ada
- ✅ Folder structure lengkap

### B. Test One-Liner Installer

```bash
# Copy URL ini (ganti USERNAME-KAMU):
https://raw.githubusercontent.com/USERNAME-KAMU/vpn-multi-manager/main/install.sh

# Test di VPS:
bash <(curl -sL https://raw.githubusercontent.com/USERNAME-KAMU/vpn-multi-manager/main/install.sh)
```

---

## STEP 8: Update README.md dengan URL yang Benar

```bash
nano /data/data/com.termux/files/home/ai/vpn/README.md
```

**Cari dan ganti:**
```markdown
# BEFORE:
bash <(curl -sL https://raw.githubusercontent.com/yourusername/vpn-multi-manager/main/install.sh)

# AFTER:
bash <(curl -sL https://raw.githubusercontent.com/USERNAME-KAMU/vpn-multi-manager/main/install.sh)
```

**Commit & push:**
```bash
git add README.md
git commit -m "Update installation URL in README"
git push
```

---

## ✅ SELESAI!

Repository kamu sekarang sudah LIVE di GitHub!

### Share Link Kamu:
```
Repository: https://github.com/USERNAME-KAMU/vpn-multi-manager
Installation: bash <(curl -sL https://raw.githubusercontent.com/USERNAME-KAMU/vpn-multi-manager/main/install.sh)
```

---

## 🔄 CARA UPDATE CODE NANTI (Kalau Ada Perubahan)

### 1. Edit file yang mau diubah

```bash
nano /data/data/com.termux/files/home/ai/vpn/scripts/profile-create
# Edit sesuai kebutuhan
```

### 2. Check perubahan

```bash
git status
git diff
```

### 3. Commit & Push

```bash
# Add file yang berubah
git add scripts/profile-create

# Atau add semua file yang berubah:
git add .

# Commit dengan message jelas
git commit -m "Fix: profile creation error handling"

# Push ke GitHub
git push
```

---

## 🆘 TROUBLESHOOTING

### Problem 1: "fatal: not a git repository"
```bash
# Solution: Init git dulu
cd /data/data/com.termux/files/home/ai/vpn
git init
```

### Problem 2: "remote origin already exists"
```bash
# Solution: Remove old remote
git remote remove origin
git remote add origin https://github.com/USERNAME-KAMU/vpn-multi-manager.git
```

### Problem 3: "Permission denied (publickey)"
```bash
# Solution: Pakai HTTPS bukan SSH
git remote set-url origin https://github.com/USERNAME-KAMU/vpn-multi-manager.git
```

### Problem 4: "Authentication failed"
```bash
# Solution: Pakai Personal Access Token, bukan password!
# Lihat STEP 5 untuk buat token
```

### Problem 5: "Updates were rejected"
```bash
# Solution: Pull dulu sebelum push
git pull origin main --rebase
git push
```

---

## 📝 CHEAT SHEET GIT COMMANDS

```bash
# Status repository
git status

# Lihat perubahan
git diff

# Add file
git add filename.sh
git add .  # Add semua

# Commit
git commit -m "Message"

# Push ke GitHub
git push

# Pull dari GitHub
git pull

# Lihat history
git log --oneline

# Undo changes (belum di-commit)
git checkout -- filename.sh

# Undo commit terakhir (keep changes)
git reset --soft HEAD~1

# Create new branch
git branch feature-name
git checkout feature-name

# Merge branch
git checkout main
git merge feature-name
```

---

## 🎯 BEST PRACTICES

1. **Commit message yang jelas:**
   - ❌ "update"
   - ✅ "Fix: SSL certificate auto-renewal issue"

2. **Commit sering:**
   - Jangan tunggu banyak perubahan
   - 1 feature = 1 commit

3. **Jangan commit file sensitive:**
   - .env (sudah ada di .gitignore)
   - passwords
   - private keys

4. **Test sebelum push:**
   - Pastikan code tidak error
   - Test di local dulu

---

**GOOD LUCK! 🚀**

Kalau ada masalah, kasih tau ya!
