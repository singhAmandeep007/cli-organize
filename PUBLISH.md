# Publishing to GitHub

This guide walks you through publishing all three repositories to GitHub and linking them with submodules.

## Prerequisites

- [GitHub CLI](https://cli.github.com/) installed (`brew install gh`)
- Authenticated: `gh auth login`

---

## Step 1: Create GitHub Repositories

Create all three repos on GitHub (public by default — add `--private` if desired):

```bash
gh repo create cli-organize --public --description "CLI file organizer — parent repo with multi-language implementations"
gh repo create cli-organize-go --public --description "CLI file organizer in Go"
gh repo create cli-organize-py --public --description "CLI file organizer in Python"
```

## Step 2: Push the Sub-Repos First

Sub-repos must be pushed before the parent so the submodule references resolve.

### Go repo

```bash
cd /path/to/cli-organize-go
git remote add origin git@github.com:singhAmandeep007/cli-organize-go.git
git push -u origin main
```

### Python repo

```bash
cd /path/to/cli-organize-py
git remote add origin git@github.com:singhAmandeep007/cli-organize-py.git
git push -u origin main
```

## Step 3: Update Submodule URLs in Parent

The `.gitmodules` file currently uses relative local paths. Update them to GitHub URLs:

```bash
cd /path/to/cli-organize
git config --file .gitmodules submodule.cli-organize-go.url git@github.com:singhAmandeep007/cli-organize-go.git
git config --file .gitmodules submodule.cli-organize-py.url git@github.com:singhAmandeep007/cli-organize-py.git
```

Also update the git config for the submodules:

```bash
git submodule sync
```

Stage and commit the URL change:

```bash
git add .gitmodules
git commit -m "chore: update submodule URLs to GitHub remotes"
```

## Step 4: Push the Parent Repo

```bash
git remote add origin git@github.com:singhAmandeep007/cli-organize.git
git push -u origin main
```

---

## Cloning (for others / new machines)

### Full clone with submodules

```bash
git clone --recurse-submodules git@github.com:singhAmandeep007/cli-organize.git
```

### If already cloned without submodules

```bash
git submodule update --init --recursive
```

---

## Updating Submodules

When you push new commits to a sub-repo, update the parent to track the latest:

```bash
cd cli-organize
git submodule update --remote cli-organize-go   # or cli-organize-py
git add cli-organize-go
git commit -m "chore: bump cli-organize-go submodule"
git push
```

---

## Using HTTPS Instead of SSH

If you prefer HTTPS over SSH, replace `git@github.com:` with `https://github.com/` in all URLs above. For example:

```
https://github.com/singhAmandeep007/cli-organize-go.git
```

---

## Quick Reference

| Repo | GitHub URL |
|------|-----------|
| Parent | `github.com/singhAmandeep007/cli-organize` |
| Go | `github.com/singhAmandeep007/cli-organize-go` |
| Python | `github.com/singhAmandeep007/cli-organize-py` |
