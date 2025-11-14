#!/bin/bash

################################################################################
# MapleJuris AI - Clone All Repositories (Safe Version)
# 
# Clones all organization repositories locally, but ONLY if:
#   - The directory does not exist, OR
#   - The directory exists AND is a valid Git repository
#
# Prevents overwriting or cloning inside non-git directories.
################################################################################

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ORG_NAME="MapleJurisAI"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}🍁 Cloning MapleJuris AI Repos 🍁${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Create repos directory
echo -e "${YELLOW}Creating repos directory (if missing)...${NC}"
mkdir -p repos
cd repos

# List of repositories
REPOS=(
    "maplejuris-api"
    "maplejuris-web"
    "maplejuris-data"
    "maplejuris-infrastructure"
    "maplejuris-docs"
)

# Clone each repository safely
for repo in "${REPOS[@]}"; do
    echo -e "\n${YELLOW}Processing ${repo}...${NC}"

    # Case 1: Directory exists AND is a git repo → pull latest
    if [ -d "${repo}" ] && [ -d "${repo}/.git" ]; then
        echo -e "${YELLOW}⚠️  ${repo} exists and is a Git repository. Pulling latest...${NC}"
        cd "${repo}"
        git pull
        cd ..
        continue
    fi

    # Case 2: Directory exists BUT is NOT a git repo → skip safely
    if [ -d "${repo}" ] && [ ! -d "${repo}/.git" ]; then
        echo -e "${RED}❌ Skipping ${repo}: directory exists but is NOT a Git repository.${NC}"
        echo -e "${RED}   Please remove or rename the folder manually if you want to re-clone.${NC}"
        continue
    fi

    # Case 3: Directory does not exist → clone it
    echo -e "${YELLOW}Cloning ${repo} from GitHub...${NC}"
    gh repo clone "${ORG_NAME}/${repo}"
    echo -e "${GREEN}✅ Successfully cloned ${repo}${NC}"
done

echo -e "\n${BLUE}========================================${NC}"
echo -e "${GREEN}✅ All repositories processed!${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${GREEN}Repository locations:${NC}"
for repo in "${REPOS[@]}"; do
    echo -e "  📁 repos/${repo}"
done

echo -e "\n${YELLOW}To work on a repository:${NC}"
echo -e "  cd repos/maplejuris-api"
echo -e "  git checkout dev"
echo -e "  git checkout -b feature/my-new-feature"

echo -e "\n${BLUE}========================================${NC}"
