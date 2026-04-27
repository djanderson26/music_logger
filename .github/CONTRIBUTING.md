# Contributing to Music Logger

Thank you for your interest in contributing! This guide explains how to work on the project.

## 🏗️ Project Structure

```
music_logger_app/lib/
├── core/            # App-wide constants, themes, utilities, errors
├── domain/          # Pure Dart business logic (entities, repository interfaces)
├── data/            # Implementation (models, repositories, datasources)
└── presentation/    # UI layer (screens, widgets, providers)
```

### Architecture Principles
- **Domain**: No Flutter imports, pure business logic
- **Data**: Implements domain repositories, handles APIs and local storage
- **Presentation**: UI only, uses Riverpod for state management

## 🔄 Development Workflow

### 1. Pick an Issue
- Go to [Issues](https://github.com/djanderson26/music_logger/issues)
- Choose an issue labeled `🔜 Up Next` (or assign yourself)
- Comment: "I'm working on this" to avoid duplicates

### 2. Create a Branch
```bash
git checkout develop
git pull origin develop
git checkout -b feature/your-feature-name
```

### 3. Commit Often
```bash
# Small, meaningful commits
git commit -m "feat: add album detail header with cover art"
git commit -m "fix: handle missing artwork gracefully"
```

### 4. Push and Create a PR
```bash
git push origin feature/your-feature-name
```
Then open a Pull Request on GitHub → `develop` branch.

## 📋 Commit Message Convention
Follow [Conventional Commits](https://www.conventionalcommits.org/):
- `feat:` new feature
- `fix:` bug fix
- `refactor:` code cleanup
- `docs:` documentation
- `test:` tests
- `chore:` maintenance

**Example:**
```
feat: add star rating widget for albums

- Creates interactive 1-5 star widget
- Supports read-only and editable modes
- Works in dark and light themes

Closes #42
```

## 🛠️ Code Style

### Dart/Flutter
- Use `flutter format .` before committing
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart)
- Run `flutter analyze` and fix all warnings

### File Organization
```dart
// 1. Imports (dart, flutter, packages, relative)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/album.dart';

// 2. Constants & types
const double _padding = 16.0;

// 3. Widget/Class definition
class MyWidget extends StatelessWidget {
  // Fields
  final String name;
  
  // Constructor
  const MyWidget({required this.name});
  
  // Methods
  @override
  Widget build(BuildContext context) { ... }
}
```

## 🧪 Testing
**Write tests for:**
- Models and entities
- Repository implementations
- Widgets

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/models/album_test.dart

# Watch mode
flutter test --watch
```

## 🚀 Before Submitting a PR

1. ✅ Branch off `develop`
2. ✅ Tests pass: `flutter test`
3. ✅ No warnings: `flutter analyze`
4. ✅ Code formatted: `flutter format .`
5. ✅ PR description references the issue: "Closes #123"

## 📚 Phase 1 Milestones

See [README.md](../README.md#development-phases) for current Phase 1 scope.

**Current Focus:** M1 – Project Foundation (bottom nav, basic screens, theme)

## 🤔 Questions?

- Check the [README](../README.md) first
- Review similar issues/PRs for patterns
- Ask in the PR description or comment on the issue

---

**Happy coding! 🎵**
