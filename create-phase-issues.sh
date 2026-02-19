#!/usr/bin/env bash

# Script to create GitHub issues for each phase in TODO.md
# This script parses TODO.md and creates corresponding GitHub issues
#
# Usage:
#   ./create-phase-issues.sh          # Create issues (requires gh auth)
#   ./create-phase-issues.sh --dry-run # Preview issues without creating them
#
# Requirements:
#   - GitHub CLI (gh) installed
#   - Authenticated with gh (run: gh auth login)
#   - Appropriate permissions to create issues in the repository

set -e

# Repository details
REPO="jordantrizz/zsh-skill"

# Parse command line arguments
DRY_RUN=false
if [[ "$1" == "--dry-run" ]]; then
    DRY_RUN=true
fi

# Color output helpers
blue() { echo -e "\033[34m$1\033[0m"; }
green() { echo -e "\033[32m$1\033[0m"; }
red() { echo -e "\033[31m$1\033[0m"; }
cyan() { echo -e "\033[36m$1\033[0m"; }
yellow() { echo -e "\033[33m$1\033[0m"; }

if [[ "$DRY_RUN" == true ]]; then
    yellow "DRY RUN MODE - No issues will be created"
    echo ""
else
    blue "Creating GitHub issues for TODO.md phases..."
    echo ""
fi

# Check if gh is available
if ! command -v gh &> /dev/null; then
    red "Error: GitHub CLI (gh) is not installed"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated (only if not dry-run)
if [[ "$DRY_RUN" == false ]]; then
    if ! gh auth status &> /dev/null; then
        red "Error: Not authenticated with GitHub CLI"
        echo "Run: gh auth login"
        exit 1
    fi
fi

# Declare associative arrays (bash 4+)
declare -A phase_statuses
declare -A phase_contents
declare -a phase_order

current_phase=""
current_content=""

# Read TODO.md line by line
while IFS= read -r line; do
    # Match phase headers (e.g., "## Phase 1: Foundation")
    if [[ $line =~ ^##\ (Phase\ [0-9]+):\ (.+)$ ]]; then
        # Save previous phase content if exists
        if [[ -n $current_phase ]]; then
            phase_contents[$current_phase]=$current_content
        fi
        
        current_phase="${BASH_REMATCH[1]}: ${BASH_REMATCH[2]}"
        phase_order+=("$current_phase")
        current_content=""
        continue
    fi
    
    # Match Future Considerations as a special phase
    if [[ $line =~ ^##\ Future\ Considerations$ ]]; then
        # Save previous phase content if exists
        if [[ -n $current_phase ]]; then
            phase_contents[$current_phase]=$current_content
        fi
        
        current_phase="Future Considerations"
        phase_order+=("$current_phase")
        current_content=""
        continue
    fi
    
    # Match status line (don't add to content)
    if [[ $line =~ ^\*\*Status:\*\*\ (.+)$ ]]; then
        phase_statuses[$current_phase]="${BASH_REMATCH[1]}"
        continue
    fi
    
    # Skip if no current phase
    if [[ -z $current_phase ]]; then
        continue
    fi
    
    # Stop collecting content when we hit another major section
    if [[ $line =~ ^##\ (Repository\ Name\ Suggestions|Notes) ]]; then
        # Save current phase content
        if [[ -n $current_phase ]]; then
            phase_contents[$current_phase]=$current_content
        fi
        current_phase=""
        current_content=""
        continue
    fi
    
    # Collect content for current phase
    if [[ -n $current_phase ]]; then
        current_content+="$line"$'\n'
    fi
done < TODO.md

# Save the last phase content
if [[ -n $current_phase ]]; then
    phase_contents[$current_phase]=$current_content
fi

# Create issues for each phase
issue_count=0
for phase in "${phase_order[@]}"; do
    cyan "Processing: $phase"
    
    # Get status
    status="${phase_statuses[$phase]:-Planned}"
    
    # Get content
    content="${phase_contents[$phase]:-No content available}"
    
    # Prepare issue body
    issue_body="**Status:** $status"$'\n\n'
    issue_body+="This issue tracks the implementation of $phase as outlined in TODO.md."$'\n\n'
    issue_body+="## Tasks"$'\n\n'
    issue_body+="$content"
    issue_body+=$'\n'"---"$'\n\n'
    issue_body+="See [TODO.md](https://github.com/$REPO/blob/main/TODO.md) for full context."
    
    # Determine labels based on phase and status
    labels="documentation,enhancement"
    if [[ $status == "In Progress" ]]; then
        labels+=",in-progress"
    fi
    
    # Create the issue
    issue_title="$phase"
    
    if [[ "$DRY_RUN" == true ]]; then
        echo "  Title: $issue_title"
        echo "  Status: $status"
        echo "  Labels: $labels"
        echo "  Content length: ${#content} chars"
        echo ""
    else
        echo "$issue_body" | gh issue create \
            --repo "$REPO" \
            --title "$issue_title" \
            --body-file - \
            --label "$labels" && {
            green "✓ Created issue for: $phase"
            ((issue_count++))
        } || {
            red "Failed to create issue for: $phase"
        }
        echo ""
        
        # Small delay to avoid rate limiting
        sleep 1
    fi
done

if [[ "$DRY_RUN" == true ]]; then
    yellow "DRY RUN COMPLETE - Would have created ${#phase_order[@]} issues"
    echo ""
    echo "To create these issues, run:"
    echo "  ./create-phase-issues.sh"
else
    green "✓ Successfully created $issue_count out of ${#phase_order[@]} issues"
    echo ""
    echo "View issues at: https://github.com/$REPO/issues"
fi
