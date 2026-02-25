# Quick Checklist: Creating GitHub Issues

This is a quick reference for creating the GitHub issues for TODO.md phases.

## ✅ Pre-Flight Checklist

- [ ] Merge the PR containing the issue creation scripts
- [ ] GitHub CLI (gh) is installed
- [ ] Authenticated with GitHub (`gh auth login`)
- [ ] Have permissions to create issues in the repository

## 🚀 Create Issues (Choose One Method)

### Method 1: Automated (Fastest - 10 seconds) ⚡

```bash
./create-phase-issues.sh
```

### Method 2: Preview Then Create 👀

```bash
# Preview first
./create-phase-issues.sh --dry-run

# If everything looks good, create
./create-phase-issues.sh
```

### Method 3: Manual (Slowest - 15 minutes) ✋

See `MANUAL_ISSUE_CREATION.md` for copy-paste templates

## ✅ Post-Creation Checklist

- [ ] Verify all 9 issues were created
- [ ] Check issues have correct labels
- [ ] Confirm tasks appear as checkboxes
- [ ] Verify links to TODO.md work
- [ ] Consider creating milestones for phases
- [ ] Assign issues to team members (optional)
- [ ] Add issues to a project board (optional)

## 🔍 Verification Commands

```bash
# List all issues
gh issue list --repo jordantrizz/zsh-skill

# View specific issue
gh issue view 1 --repo jordantrizz/zsh-skill

# Count issues
gh issue list --repo jordantrizz/zsh-skill --state open | wc -l
```

## 📊 Expected Results

- **Issues created**: 9
- **Labels used**: documentation, enhancement, in-progress
- **Total tasks**: 92
- **Completed tasks**: 5 (in Phase 1)
- **Time taken**: ~10-15 seconds

## 🆘 Troubleshooting

### Script fails with authentication error
```bash
gh auth login
# Then try again
./create-phase-issues.sh
```

### GitHub CLI not installed
See installation instructions in `INSTRUCTIONS.md`

### Script fails partway through
Check which issues were created:
```bash
gh issue list
```
Create remaining issues manually using `MANUAL_ISSUE_CREATION.md`

### Want to see what will be created first
```bash
./create-phase-issues.sh --dry-run
```

## 📖 Documentation

- **Quick start**: `INSTRUCTIONS.md`
- **Detailed docs**: `CREATE_ISSUES_README.md`
- **What's created**: `ISSUES_SUMMARY.md`
- **Manual method**: `MANUAL_ISSUE_CREATION.md`
- **Full summary**: `SUMMARY.md`

## 🎯 One-Liner

If you're ready to go:

```bash
gh auth login && ./create-phase-issues.sh
```

---

**Ready?** Run: `./create-phase-issues.sh` ✨
