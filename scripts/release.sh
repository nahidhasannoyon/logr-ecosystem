#!/bin/bash

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh <version>"
    exit 1
fi

echo "🚀 Starting release process for v${VERSION}"

# 1. Ensure clean working directory
if [ -n "$(git status --short)" ]; then
    echo "❌ Working directory not clean"
    exit 1
fi

# 2. Update versions
echo "📝 Updating versions..."
melos version --no-git-tag-version

# 3. Run tests
echo "🧪 Running tests..."
melos run test:all
if [ $? -ne 0 ]; then
    echo "❌ Tests failed"
    exit 1
fi

# 4. Commit
echo "📦 Committing changes..."
git add -A
git commit -m "chore: release v${VERSION}"

# 5. Create branch and tag
echo "🏷️  Creating tag..."
git tag "v${VERSION}"

# 6. Push
echo "🚀 Pushing to GitHub..."
git push origin main
git push origin "v${VERSION}"

echo "✅ Release v${VERSION} completed!"
