# How to Create GitHub Issues from TODO.md Phases

## Overview

This directory contains everything you need to create GitHub issues for each phase in TODO.md.

## Files Created

1. **`create-phase-issues.sh`** - Automated script to create all issues
2. **`CREATE_ISSUES_README.md`** - Detailed script documentation
3. **`ISSUES_SUMMARY.md`** - Summary of all issues to be created
4. **`MANUAL_ISSUE_CREATION.md`** - Manual creation guide (if script fails)
5. **`INSTRUCTIONS.md`** (this file) - Quick start guide

## Quick Start (Recommended)

### Step 1: Authenticate with GitHub CLI

```bash
gh auth login
```

Follow the prompts to authenticate.

### Step 2: Run the Script

```bash
./create-phase-issues.sh
```

This will create all 9 issues automatically.

## Alternative: Preview First (Dry Run)

To see what will be created without actually creating issues:

```bash
./create-phase-issues.sh --dry-run
```

## What Will Be Created

The script will create **9 GitHub issues**:

1. **Phase 1: Foundation ✅ (Current)** - In Progress (7 tasks)
2. **Phase 2: Content Enhancement** - Planned (12 tasks)
3. **Phase 3: Interactive Components** - Planned (11 tasks)
4. **Phase 4: Testing & Quality** - Planned (11 tasks)
5. **Phase 5: AI Integration** - Planned (13 tasks)
6. **Phase 6: Advanced Features** - Planned (11 tasks)
7. **Phase 7: Community & Ecosystem** - Planned (10 tasks)
8. **Phase 8: Maintenance & Updates** - Planned (9 tasks)
9. **Future Considerations** - Planned (8 tasks)

**Total: 92 tasks across 9 issues**

## Each Issue Includes

- ✅ Phase title and status
- ✅ All tasks as checkboxes
- ✅ Link back to TODO.md
- ✅ Appropriate labels (documentation, enhancement)
- ✅ Additional "in-progress" label for Phase 1

## Troubleshooting

### "GitHub CLI (gh) is not installed"

Install from: https://cli.github.com/

On Ubuntu/Debian:
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

On macOS:
```bash
brew install gh
```

### "Not authenticated with GitHub CLI"

Run:
```bash
gh auth login
```

### Script Still Doesn't Work?

Use the manual method in `MANUAL_ISSUE_CREATION.md`:
1. Open the file
2. Copy each issue template
3. Create manually at: https://github.com/jordantrizz/zsh-skill/issues/new

## Verification

After running the script, verify issues were created:

```bash
gh issue list --repo jordantrizz/zsh-skill
```

Or visit: https://github.com/jordantrizz/zsh-skill/issues

## Next Steps After Creating Issues

1. Review all created issues
2. Consider creating milestones for major phases
3. Assign issues to team members
4. Use issue references in commits:
   - `Fixes #1` - Closes the issue
   - `Related to #2` - Links to the issue
5. Track progress through the GitHub Projects board

## Script Features

- ✅ Dry-run mode for preview
- ✅ Colored output for clarity
- ✅ Error handling
- ✅ Rate limit protection (1-second delay between issues)
- ✅ Authentication verification
- ✅ Preserves task formatting and checkboxes

## Support

If you encounter issues:

1. Check `CREATE_ISSUES_README.md` for detailed documentation
2. Review `ISSUES_SUMMARY.md` for expected output
3. Use `MANUAL_ISSUE_CREATION.md` as a fallback
4. Open an issue in the repository for help

## Example Run

```bash
$ ./create-phase-issues.sh
Creating GitHub issues for TODO.md phases...

Processing: Phase 1: Foundation ✅ (Current)
✓ Created issue for: Phase 1: Foundation ✅ (Current)

Processing: Phase 2: Content Enhancement
✓ Created issue for: Phase 2: Content Enhancement

...

✓ Successfully created 9 out of 9 issues

View issues at: https://github.com/jordantrizz/zsh-skill/issues
```

---

**Ready to create issues?** Run: `./create-phase-issues.sh`

**Want to preview first?** Run: `./create-phase-issues.sh --dry-run`

**Need help?** Check `CREATE_ISSUES_README.md`
