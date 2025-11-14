#!/usr/bin/env bash
# MapleJuris AI - Project Board Setup Script
# Creates one organization-level project board that tracks work across all repositories
#
# Prerequisites:
#   1. GitHub CLI installed: brew install gh
#   2. Authenticated: gh auth login
#   3. Authenticated with project scope: gh auth refresh -s project
#   4. Organization exists: MapleJurisAI
#   5. Repositories created (run setup-org.sh first)
#
# Usage:
#   bash setup-projects.sh

# ============================================================================
# STRICT MODE
# ============================================================================
set -euo pipefail
IFS=$'\n\t'

# ============================================================================
# CONFIGURATION
# ============================================================================
readonly ORG_NAME="MapleJurisAI"
readonly PROJECT_NAME="MapleJuris"

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

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
    
    if ! command -v "$cmd" &> /dev/null; then
        log_error "Required command not found: $cmd"
        log_info "Install: brew install gh"
        log_info ""
        log_info "If using conda, fix your PATH:"
        log_info "  export PATH=\"/opt/homebrew/bin:\$PATH\""
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
        log_info "Create it at: https://github.com/account/organizations/new"
        return 1
    fi
    return 0
}

check_project_permissions() {
    log_info "Checking project permissions..."
    
    if gh project list --owner "$ORG_NAME" &> /dev/null; then
        return 0
    else
        log_error "Missing required GitHub scopes for projects"
        log_info "Run this command to add permissions:"
        log_info "  gh auth refresh -s project"
        log_info ""
        log_info "Then run this script again"
        return 1
    fi
}

# ============================================================================
# PROJECT FUNCTIONS
# ============================================================================
create_project() {
    local title=$1
    
    log_info "Creating project: $title"
    
    if gh project create \
        --owner "$ORG_NAME" \
        --title "$title" \
        > /dev/null 2>&1; then
        log_success "Created project: $title"
        return 0
    else
        log_warning "Could not create project: $title (may already exist)"
        return 0  # Return success anyway - not a fatal error
    fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================
main() {
    echo "🍁 MapleJuris AI Project Board Setup"
    echo "====================================="
    echo ""
    
    # Perform checks
    log_info "Running prerequisite checks..."
    
    check_command "gh" || exit 1
    check_gh_auth || exit 1
    check_org_exists "$ORG_NAME" || exit 1
    check_project_permissions || exit 1
    
    log_success "All checks passed!"
    echo ""
    
    # Confirmation
    log_info "This will create ONE organization-level project board:"
    echo "  - Project: '$PROJECT_NAME'"
    echo "  - Tracks all issues/PRs from all 5 repositories"
    echo "  - You can create multiple views inside it"
    echo ""
    
    read -r -p "Continue? (y/n) " answer
    if [[ ! $answer =~ ^[Yy]$ ]]; then
        log_info "Aborted by user"
        exit 0
    fi
    
    # Create project
    echo ""
    log_info "📊 Creating Project Board..."
    echo ""
    
    create_project "$PROJECT_NAME"
    
    # Success message
    echo ""
    echo "====================================="
    log_success "Project Board Created!"
    echo "====================================="
    echo ""
    log_info "View your project at:"
    echo "  https://github.com/orgs/$ORG_NAME/projects"
    echo ""
    log_info "🎯 Next Steps - Configure Your Project Board:"
    echo ""
    echo "1. CREATE VIEWS (Different ways to see the same data):"
    echo ""
    echo "   Board View (Default Kanban):"
    echo "     - 📥 Backlog"
    echo "     - 📝 Ready"
    echo "     - 🚧 In Progress"
    echo "     - 👀 Review"
    echo "     - ✅ Done"
    echo ""
    echo "   Roadmap View (Timeline):"
    echo "     - Switch layout to 'Roadmap' to see timeline"
    echo ""
    echo "   Sprint View (Current Week):"
    echo "     - Filter: Sprint = Current"
    echo ""
    echo "   By Repository View:"
    echo "     - Group by: Repository"
    echo ""
    echo "   By Priority View:"
    echo "     - Group by: Priority"
    echo ""
    echo "2. ENABLE AUTOMATION:"
    echo "   Go to: Project → Settings → Workflows"
    echo "   Enable:"
    echo "     - Auto-add items: When issues/PRs are created"
    echo "     - Auto-archive items: When issues/PRs are closed"
    echo "     - Item opened: Move to 'In Progress'"
    echo "     - Item closed: Move to 'Done'"
    echo ""
    echo "3. ADD CUSTOM FIELDS:"
    echo "   Click '+' next to field headers to add:"
    echo ""
    echo "   Repository (Single select):"
    echo "     - maplejuris-api"
    echo "     - maplejuris-web"
    echo "     - maplejuris-data"
    echo "     - maplejuris-infrastructure"
    echo "     - maplejuris-docs"
    echo ""
    echo "   Priority (Single select):"
    echo "     - 🔴 High"
    echo "     - 🟡 Medium"
    echo "     - 🟢 Low"
    echo ""
    echo "   Size (Single select):"
    echo "     - XS (< 1 day)"
    echo "     - S (1-2 days)"
    echo "     - M (3-5 days)"
    echo "     - L (1-2 weeks)"
    echo "     - XL (2+ weeks)"
    echo ""
    echo "   Sprint (Iteration):"
    echo "     - Set up 2-week iterations"
    echo ""
    echo "   Type (Single select):"
    echo "     - Feature"
    echo "     - Bug"
    echo "     - Documentation"
    echo "     - Infrastructure"
    echo ""
    echo "4. HOW TO USE:"
    echo "   - All issues from all 5 repos automatically appear"
    echo "   - Create different views for different purposes"
    echo "   - Filter and sort in each view independently"
    echo "   - One source of truth, multiple perspectives"
    echo ""
    log_info "✨ Pro Tip: Create a 'Student Friendly' view filtered by"
    log_info "   label='good-first-issue' to help new contributors!"
    echo ""
}

# Run main function
main "$@"