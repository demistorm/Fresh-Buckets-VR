#!/bin/bash

# Check if GitHub CLI is installed
if ! command -v gh &>/dev/null; then
    echo "Error: GitHub CLI (gh) is not installed. Install it from https://cli.github.com/."
    exit 1
fi

# Get GitHub username from CLI config
GITHUB_USER=$(gh api user --jq '.login' 2>/dev/null)
if [ -z "$GITHUB_USER" ]; then
    echo "Error: You are not logged into GitHub CLI. Run: gh auth login"
    exit 1
fi

# Ask for repo name
read -p "Enter the GitHub repository name: " reponame

# Check if the repo exists
if gh repo view "$GITHUB_USER/$reponame" &>/dev/null; then
    echo "ℹ️ Repository '$reponame' already exists on GitHub."
    echo "Pushing updates..."

    if [ ! -d .git ]; then
        echo "Error: This folder is not a git repository. Run script in correct folder."
        exit 1
    fi

    git add .
    read -p "Enter commit message: " commitmsg
    git commit -m "$commitmsg"
    git push
    echo "✅ Changes pushed to existing repository."

else
    echo "ℹ️ Repository '$reponame' does not exist. Creating..."
    read -p "Public or private? (public/private): " visibility

    # Initialize git if needed
    if [ ! -d .git ]; then
        git init
    fi

    git add .
    read -p "Enter commit message: " commitmsg
    git commit -m "$commitmsg"

    # Create repo and push
    gh repo create "$reponame" --$visibility --source=. --remote=origin --push
    echo "✅ New repository '$reponame' created and uploaded."
fi
