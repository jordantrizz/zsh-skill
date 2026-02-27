#!/usr/bin/env sh
# skills_format_spec.sh - Validate skills file formats

Describe 'YAML files in .github/'
  validate_yaml() {
    python3 -c "import sys, yaml; yaml.safe_load(open(sys.argv[1]))" "$1" 2>&1
  }

  It '.github/ISSUE_TEMPLATE/bug_report.yml is valid YAML'
    When run validate_yaml "${SHELLSPEC_SPECDIR}/../.github/ISSUE_TEMPLATE/bug_report.yml"
    The status should be success
  End

  It '.github/ISSUE_TEMPLATE/feature_request.yml is valid YAML'
    When run validate_yaml "${SHELLSPEC_SPECDIR}/../.github/ISSUE_TEMPLATE/feature_request.yml"
    The status should be success
  End

  It '.github/workflows/ci.yml is valid YAML'
    When run validate_yaml "${SHELLSPEC_SPECDIR}/../.github/workflows/ci.yml"
    The status should be success
  End
End

Describe 'skills/zsh-coding-standards/SKILL.md front matter'
  skill_file="${SHELLSPEC_SPECDIR}/../skills/zsh-coding-standards/SKILL.md"

  It 'SKILL.md exists'
    The file "${skill_file}" should be exist
  End

  It 'SKILL.md starts with a YAML front matter block (---)'
    check_frontmatter_open() {
      head -1 "${skill_file}"
    }
    When run check_frontmatter_open
    The output should eq '---'
  End

  It 'SKILL.md front matter contains a name field'
    check_name() {
      sed -n '/^---$/,/^---$/p' "${skill_file}" | grep -c "^name:"
    }
    When run check_name
    The output should eq '1'
  End

  It 'SKILL.md front matter contains a description field'
    check_description() {
      sed -n '/^---$/,/^---$/p' "${skill_file}" | grep -c "^description:"
    }
    When run check_description
    The output should eq '1'
  End

  It 'SKILL.md front matter is valid YAML'
    check_frontmatter_yaml() {
      awk '/^---$/{f=!f; if(!f) exit; next} f{print}' "${skill_file}" \
        | python3 -c "import sys, yaml; yaml.safe_load(sys.stdin)" 2>&1
    }
    When run check_frontmatter_yaml
    The status should be success
  End
End
