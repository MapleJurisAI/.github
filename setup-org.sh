#!/usr/bin/env bash
# MapleJuris AI - Organization Setup Script
# Creates 5 repositories with branches and basic protection rules
#
# Prerequisites:
#   1. Install GitHub CLI: brew install gh (Mac) or winget install GitHub.cli (Windows)
#   2. Login: gh auth login
#   3. Create organization manually at: https://github.com/account/organizations/new
#      Organization name: MapleJurisAI
#
# Usage:
#   bash setup-org.sh

# ============================================================================
# STRICT MODE - Exit on errors, undefined variables, and pipe failures
# ============================================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION - CHANGE THIS!
# ============================================================================
readonly ORG_NAME="MapleJurisAI"
readonly ADMIN_USERNAME="${ADMIN_USERNAME:-AbduKhRadi}"  # Can be overridden by env var

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✅${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}❌${NC} $1" >&2
}

# ============================================================================
# ERROR HANDLER
# ============================================================================
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "Script failed with exit code: $exit_code"
        log_info "Check the error message above for details"
    fi
}

trap cleanup EXIT

# ============================================================================
# VALIDATION FUNCTIONS
# ============================================================================
check_command() {
    local cmd=$1
    local install_hint=$2
    
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Required command not found: $cmd"
        log_info "$install_hint"
        return 1
    fi
    return 0
}

check_gh_auth() {
    if ! gh auth status &> /dev/null; then
        log_error "Not authenticated with GitHub"
        log_info "Run: gh auth login"
        return 1
    fi
    return 0
}

check_org_exists() {
    local org=$1
    
    if ! gh api "orgs/$org" &> /dev/null; then
        log_error "Organization '$org' not found"
        echo ""
        log_info "Create it manually at: https://github.com/account/organizations/new"
        log_info "Organization name: $org"
        return 1
    fi
    return 0
}

check_admin_username() {
    if [ "$ADMIN_USERNAME" = "YOUR_GITHUB_USERNAME" ]; then
        log_error "Please set ADMIN_USERNAME in the script"
        log_info "Edit line 18 or set environment variable:"
        log_info "  export ADMIN_USERNAME=your-github-username"
        log_info "  bash setup-org.sh"
        return 1
    fi
    return 0
}

# ============================================================================
# REPOSITORY FUNCTIONS
# ============================================================================
repo_exists() {
    local org=$1
    local repo=$2
    gh repo view "$org/$repo" &> /dev/null
}

create_repo() {
    local repo_name=$1
    local description=$2
    
    log_info "Creating repository: $repo_name"
    
    if repo_exists "$ORG_NAME" "$repo_name"; then
        log_warning "Repository already exists: $repo_name (skipping)"
        return 0
    fi
    
    if gh repo create "$ORG_NAME/$repo_name" \
        --public \
        --description "$description" \
        --license mit \
        --enable-issues \
        --enable-wiki; then
        log_success "Created: $repo_name"
        sleep 2  # Rate limiting
        return 0
    else
        log_error "Failed to create repository: $repo_name"
        return 1
    fi
}

create_branches() {
    local repo_name=$1
    
    log_info "Setting up branches for: $repo_name"
    
    # Create temporary directory
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Ensure cleanup on function exit
    trap "rm -rf '$temp_dir'" RETURN
    
    # Clone repository
    if ! gh repo clone "$ORG_NAME/$repo_name" "$temp_dir/$repo_name" &> /dev/null; then
        log_error "Failed to clone: $repo_name"
        return 1
    fi
    
    cd "$temp_dir/$repo_name" || return 1
    
    # Create staging branch
    if ! git checkout -b staging &> /dev/null; then
        log_warning "Staging branch may already exist"
    fi
    git push origin staging &> /dev/null || true
    
    # Create dev branch
    if ! git checkout -b dev &> /dev/null; then
        log_warning "Dev branch may already exist"
    fi
    git push origin dev &> /dev/null || true
    
    # Set dev as default branch
    if gh api -X PATCH "repos/$ORG_NAME/$repo_name" \
        -f default_branch=dev &> /dev/null; then
        log_success "Branches created: main, staging, dev"
    else
        log_warning "Could not set default branch to dev"
    fi
    
    cd - &> /dev/null || true
    sleep 2
    
    return 0
}

protect_branch() {
    local repo_name=$1
    local branch=$2
    local approvals=$3
    
    log_info "Protecting: $repo_name/$branch (requires $approvals approval(s))"
    
    if gh api -X PUT "repos/$ORG_NAME/$repo_name/branches/$branch/protection" \
        -f required_pull_request_reviews="{\"required_approving_review_count\":$approvals}" \
        -f enforce_admins=true \
        -f required_linear_history=true \
        -f allow_force_pushes=false \
        &> /dev/null; then
        log_success "Protected: $repo_name/$branch"
        sleep 1
        return 0
    else
        log_warning "Could not protect branch: $repo_name/$branch"
        return 1
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
main() {
    echo "🍁 MapleJuris AI Organization Setup"
    echo "===================================="
    echo ""
    
    # Perform all checks
    log_info "Running prerequisite checks..."
    
    check_command "gh" "Install: brew install gh (Mac) or winget install GitHub.cli (Windows)" || exit 1
    check_gh_auth || exit 1
    check_org_exists "$ORG_NAME" || exit 1
    check_admin_username || exit 1
    
    log_success "All checks passed!"
    echo ""
    
    # Confirmation
    log_info "This will create 5 public repositories with:"
    echo "  - MIT License"
    echo "  - main, staging, dev branches"
    echo "  - Branch protection rules"
    echo ""
    
    read -r -p "Continue? (y/n) " answer
    if [[ ! $answer =~ ^[Yy]$ ]]; then
        log_info "Aborted by user"
        exit 0
    fi
    
    # Repository definitions
    local -a repos=(
        "maplejuris-api:Backend API services, embeddings engine, and knowledge graph"
        "maplejuris-web:Frontend chatbot interface for MapleJuris AI"
        "maplejuris-data:Data pipeline for scraping and processing Canadian legal documents"
        "maplejuris-infrastructure:Infrastructure as Code and CI/CD pipelines"
        "maplejuris-docs:Documentation and educational resources"
    )
    
    # Create repositories
    echo ""
    log_info "📦 Creating Repositories..."
    echo ""
    
    for repo_def in "${repos[@]}"; do
        IFS=':' read -r repo_name description <<< "$repo_def"
        create_repo "$repo_name" "$description" || log_warning "Failed to create $repo_name"
    done
    
    # Create branches
    echo ""
    log_info "🌳 Creating Branches..."
    echo ""
    
    for repo_def in "${repos[@]}"; do
        IFS=':' read -r repo_name _ <<< "$repo_def"
        create_branches "$repo_name" || log_warning "Failed to create branches for $repo_name"
    done
    
    # Protect branches
    echo ""
    log_info "🔒 Protecting Branches..."
    echo ""
    
    for repo_def in "${repos[@]}"; do
        IFS=':' read -r repo_name _ <<< "$repo_def"
        protect_branch "$repo_name" "main" 2 || true
        protect_branch "$repo_name" "staging" 1 || true
    done
    
    # Success summary
    echo ""
    echo "===================================="
    log_success "Setup Complete!"
    echo "===================================="
    echo ""
    echo "Created repositories:"
    for repo_def in "${repos[@]}"; do
        IFS=':' read -r repo_name _ <<< "$repo_def"
        echo "  📦 https://github.com/$ORG_NAME/$repo_name"
    done
    echo ""
    log_info "Next steps:"
    echo "  1. Visit: https://github.com/$ORG_NAME"
    echo "  2. Run: bash clone-all-repos.sh (to clone locally)"
    echo "  3. Run: bash setup-projects.sh (to create project boards)"
    echo ""
}

# Run main function
main "$@"