# Create Phase Issues Script

This script automatically creates GitHub issues for each phase defined in `TODO.md`.

## Overview

The script parses `TODO.md` and creates a separate GitHub issue for each phase:
- Phase 1: Foundation ✅ (Current)
- Phase 2: Content Enhancement
- Phase 3: Interactive Components
- Phase 4: Testing & Quality
- Phase 5: AI Integration
- Phase 6: Advanced Features
- Phase 7: Community & Ecosystem
- Phase 8: Maintenance & Updates
- Future Considerations

Each issue includes:
- The phase status (In Progress/Planned)
- All tasks from that phase as checkboxes
- A link back to TODO.md for full context
- Appropriate labels (documentation, enhancement, and in-progress if applicable)

## Prerequisites

1. **GitHub CLI (gh)** must be installed
   - Install from: https://cli.github.com/
   - Verify with: `gh --version`

2. **Authentication** (for creating issues)
   - Run: `gh auth login`
   - Follow the prompts to authenticate

## Usage

### Preview Issues (Dry Run)

To see what issues would be created without actually creating them:

```bash
./create-phase-issues.sh --dry-run
```

This will show:
- Issue title
- Status
- Labels
- Content length

### Create Issues

To actually create the issues:

```bash
./create-phase-issues.sh
```

The script will:
1. Verify GitHub CLI is installed
2. Check authentication status
3. Parse TODO.md
4. Create an issue for each phase
5. Add a 1-second delay between issues to avoid rate limiting

## Output

The script provides colored output:
- 🔵 Blue: Informational messages
- 🟢 Green: Success messages
- 🔴 Red: Error messages
- 🔷 Cyan: Processing status
- 🟡 Yellow: Warnings and dry-run mode

## Troubleshooting

### "GitHub CLI (gh) is not installed"
Install the GitHub CLI from https://cli.github.com/

### "Not authenticated with GitHub CLI"
Run `gh auth login` and follow the authentication prompts

### "Failed to create issue"
- Check your internet connection
- Verify you have permission to create issues in the repository
- Check if you've hit GitHub API rate limits

## Notes

- The script creates issues in the order they appear in TODO.md
- Each issue gets standard labels: `documentation` and `enhancement`
- Issues with "In Progress" status also get the `in-progress` label
- There's a 1-second delay between issue creation to respect rate limits
- All issue bodies include a link back to TODO.md for context

## Example

```bash
# Preview what will be created
$ ./create-phase-issues.sh --dry-run
DRY RUN MODE - No issues will be created

Processing: Phase 1: Foundation ✅ (Current)
  Title: Phase 1: Foundation ✅ (Current)
  Status: In Progress
  Labels: documentation,enhancement,in-progress
  Content length: 369 chars
...
DRY RUN COMPLETE - Would have created 9 issues

# Actually create the issues
$ ./create-phase-issues.sh
Creating GitHub issues for TODO.md phases...

Processing: Phase 1: Foundation ✅ (Current)
✓ Created issue for: Phase 1: Foundation ✅ (Current)
...
✓ Successfully created 9 out of 9 issues

View issues at: https://github.com/jordantrizz/zsh-skill/issues
```
