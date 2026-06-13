#!/bin/bash

# 1. Establish path independence relative to script location
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Define internal parameters
EXPORT_DIR="$PROJECT_ROOT/docs" 
REPO_DIR="$PROJECT_ROOT"          
BRANCH="main"

echo "🚀 Initiating automated pipeline for Tim Supply Enterprise..."

# 2. Check if Bootstrap Studio has run its local compilation pass
if [ ! -d "$EXPORT_DIR" ]; then
    echo "❌ Error: Compilation cache directory not found at $EXPORT_DIR"
    echo "Please ensure Bootstrap Studio's Export Destination is pointed to a folder named 'docs' next to your .bsdesign file."
    exit 1
fi

# 3. Synchronize compiled static assets into the target /docs folder
echo "📦 Syncing production assets to /docs..."

# Ensure the docs directory exists safely
mkdir -p "$REPO_DIR/docs"

# 4. Enter repository root context
cd "$REPO_DIR" || exit 1

# 5. Pipeline Git execution
echo "🔄 Staging tracked updates..."
# Mute the add command to stop the line-ending warnings from triggering a Bootstrap Studio popup
git add docs/ scripts/ timsupply.bsdesign .gitignore >/dev/null 2>&1

# Verify if changes exist relative to the last head index state
if git diff-index --quiet HEAD -- 2>/dev/null; then
    if [ -z "$(git status --porcelain)" ]; then
        echo "✅ Architecture up to date. No new modifications to push."
        exit 0
    fi
fi

echo "💾 Packaging commit matrix..."
git commit -m "Automated build deployment from Bootstrap Studio: $(date '+%Y-%m-%d %H:%M:%S')" >/dev/null 2>&1

echo "📤 Pushing production branch payload to upstream remote ($BRANCH)..."
git push origin "$BRANCH" >/dev/null 2>&1

echo "🎉 Deployment sync complete! timsupply.github.io is updating."