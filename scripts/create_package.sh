#!/bin/bash
# scripts/create_package.sh

PACKAGE_NAME=$1
DESCRIPTION=$2

if [ -z "$PACKAGE_NAME" ] || [ -z "$DESCRIPTION" ]; then
    echo "Usage: ./create_package.sh <package_name> '<description>'"
    exit 1
fi

cd packages
dart create --template=package "$PACKAGE_NAME"
cd "$PACKAGE_NAME"

# Update pubspec.yaml with common settings
cat > pubspec.yaml << EOF
name: $PACKAGE_NAME
version: 0.1.0
description: $DESCRIPTION
homepage: https://github.com/Flutter-Craft/logr-ecosystem
repository: https://github.com/Flutter-Craft/logr-ecosystem
issue_tracker: https://github.com/Flutter-Craft/logr-ecosystem/issues
documentation: https://pub.dev/documentation/$PACKAGE_NAME/latest/

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  logr: ^0.1.0

dev_dependencies:
  lints: ^2.0.0
  test: ^1.22.0
  coverage: ^7.0.0

topics:
  - logging
  - dart
  - flutter
EOF

mkdir -p lib/src test/{unit,integration}
cat > lib/$PACKAGE_NAME.dart << EOF
/// $DESCRIPTION
library $PACKAGE_NAME;
EOF

cat > CHANGELOG.md << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2024-01-15

### Added
- Initial release
EOF

cp ../../../analysis_options.yaml .
cp ../../../.gitignore .

cd ..
echo "✅ $PACKAGE_NAME package created"

# Bootstrap
melos bootstrap