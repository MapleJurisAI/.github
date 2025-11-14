# MapleJuris AI - Setup Scripts

This folder contains automated scripts to set up the MapleJuris AI organization on GitHub.

## 📋 Prerequisites

Before running these scripts, you need:

1. **GitHub CLI** installed
   ```bash
   brew install gh
   ```

2. **Authenticated with GitHub**
   ```bash
   gh auth login
   ```

3. **Organization created manually** (scripts cannot do this)
   - Go to: https://github.com/account/organizations/new
   - Organization name: `MapleJurisAI`
   - Type: Educational institution ✅

## 🚀 Quick Start

### Step 1: Clone this repository
```bash
gh repo clone MapleJurisAI/.github
cd .github
```

### Step 2: Run setup scripts in order

**Important:** Always run these scripts with `bash` command, regardless of your shell:

```bash
# 1. Create all repositories and branches
bash setup-org.sh

# 2. Create project boards
bash setup-projects.sh

# 3. Clone all repos locally
bash clone-all-repos.sh
```

## 📝 Scripts Overview

### `setup-org.sh`
**Purpose:** Creates all repositories with branch structure and protection rules

**What it does:**
- Creates 5 public repositories
- Sets up branches: `main`, `staging`, `dev`
- Configures branch protection rules
- Sets `dev` as default branch

**Runtime:** ~5-10 minutes

**Usage:**
```bash
bash setup-org.sh
```

---

### `setup-projects.sh`
**Purpose:** Creates organization-level project boards

**What it does:**
- Creates 3 project boards
- Links all repositories to projects
- Sets up board templates

**Runtime:** ~30 seconds

**Usage:**
```bash
bash setup-projects.sh
```

---

### `clone-all-repos.sh`
**Purpose:** Clones all repositories to your local machine

**What it does:**
- Creates `repos/` folder
- Clones all 5 repositories
- Sets up local development environment

**Runtime:** ~1-2 minutes

**Usage:**
```bash
bash clone-all-repos.sh
```

## 🐚 Why Use `bash` Command?

**Question:** I use Zsh (or another shell), why do I need to type `bash`?

**Answer:** These scripts use Bash-specific syntax. Running them with `bash` ensures they work correctly regardless of your default shell.

### Common Shells:
- **Zsh** (default on macOS since 2019) - Use `bash scriptname.sh`
- **Bash** (older systems) - Can use `./scriptname.sh` or `bash scriptname.sh`
- **Fish** - Use `bash scriptname.sh`

### The Rule:
✅ **Always safe:** `bash setup-org.sh`  
⚠️ **May fail:** `./setup-org.sh` (depends on your shell)

## 🔧 Configuration

Before running `setup-org.sh`, edit line 18:

```bash
nano setup-org.sh
```

Change:
```bash
ADMIN_USERNAME="YOUR_GITHUB_USERNAME"
```

To your actual GitHub username.

## ✅ Verification

After running all scripts, verify:

```bash
# Check repositories exist
gh repo list MapleJurisAI

# Check projects exist
# Visit: https://github.com/orgs/MapleJurisAI/projects

# Check local clones
ls repos/
# Should show: maplejuris-api, maplejuris-web, etc.
```

## 🆘 Troubleshooting

### "GitHub CLI not found" or "command not found: brew"

**This usually happens when using conda/anaconda environments.**

**Solution:**
```bash
# Fix your PATH to include Homebrew
export PATH="/opt/homebrew/bin:$PATH"

# Verify brew works
which brew

# Verify gh works  
which gh

# Make it permanent (add to ~/.zshrc)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

**If gh is not installed at all:**
```bash
brew install gh
gh --version
```

### "Not authenticated"
```bash
# Login
gh auth login

# Follow prompts to authenticate
```

### "Organization not found"
You must create the organization manually first:
1. Go to: https://github.com/account/organizations/new
2. Name: `MapleJurisAI`
3. Then run the scripts

### "Permission denied" when running script
```bash
# Don't use ./scriptname.sh
# Instead use:
bash setup-org.sh
```

### "declare: -A: invalid option"
This means you tried to run with `./setup-org.sh` instead of `bash setup-org.sh`.

**Fix:** Always use `bash` command:
```bash
bash setup-org.sh
```

## 📚 Additional Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Git Branching Strategy](https://github.com/MapleJurisAI/maplejuris-docs)
- [Contributing Guide](https://github.com/MapleJurisAI/maplejuris-docs/blob/main/CONTRIBUTING.md)

## 🍁 Next Steps

After running these scripts:

1. Visit your organization: https://github.com/MapleJurisAI
2. Invite team members
3. Create first issues for contributors
4. Start building!

---

**Questions?** Open an issue in this repository or reach out to the maintainers.