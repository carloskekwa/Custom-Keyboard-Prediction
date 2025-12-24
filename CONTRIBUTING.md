# Contributing to PredictionKeyboard

We welcome contributions from the community! This guide will help you get started with contributing to PredictionKeyboard.

## Code of Conduct

Please be respectful and constructive in all interactions with the community and maintainers.

## Before You Start

- Review the [README.md](README.md) to understand the project
- Check [existing issues](https://github.com/carloskekwa/PredictionKeyboard/issues) to avoid duplicate work
- Read the [INTEGRATION.md](INTEGRATION.md) guide for architecture details

## Getting Started

### 1. Fork and Clone

```bash
git clone https://github.com/<your-username>/PredictionKeyboard.git
cd PredictionKeyboard
git remote add upstream https://github.com/carloskekwa/PredictionKeyboard.git
```

### 2. Set Up Development Environment

```bash
pod install
```

### 3. Create a Feature Branch

Branch names should be descriptive:
```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/issue-description
```

## Making Changes

### Code Style

- Follow Apple's Objective-C conventions
- Use `NS_ASSUME_NONNULL_BEGIN/END` for header files
- Document public methods with `///` comments
- Keep methods focused and testable

### File Organization

Changes should respect the project structure:
- **Public API**: `Sources/Public/` - exported headers
- **Models**: `Sources/Models/` - Realm models
- **Core Logic**: `Sources/Core/` - implementation
- **Utilities**: `Sources/Utilities/` - constants and helpers

### Example: Adding a Feature

```objc
// 1. Define in public header
@interface PredictionKeyboardManager (MyFeature)
- (void)myNewMethod:(NSString *)input completion:(void(^)(NSArray *results))completion;
@end

// 2. Implement in Core
- (void)myNewMethod:(NSString *)input completion:(void(^)(NSArray *results))completion {
    // Implementation
}

// 3. Export in umbrella header if public
// Add to Sources/Public/PredictionKeyboard.h
```

## Commit Guidelines

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
feat: add next-word prediction scoring
fix: resolve Realm initialization crash
docs: update keyboard extension setup
refactor: simplify prediction query logic
test: add unit tests for word completion
```

### Commit Examples

```bash
git commit -m "feat: add fuzzy matching for word completion"
git commit -m "fix: handle nil appGroupID in database path"
git commit -m "docs: clarify app group setup requirements"
```

## Testing

### Manual Testing

1. **In Main App**: Build and run Example project
   ```bash
   pod install
   open PredictionKeyboard.xcworkspace
   ```

2. **In Keyboard Extension**: Test shared database with app group

### Testing Checklist

- [ ] Predictions return expected results
- [ ] App Group container works with extensions
- [ ] Realm migrations execute without errors
- [ ] Memory leaks addressed (use Instruments)
- [ ] Existing functionality still works

## Documentation

- Update [INTEGRATION.md](INTEGRATION.md) if architecture changes
- Add code comments for complex logic
- Document breaking changes clearly
- Include usage examples for new features

### Documentation Format

```objc
/// Initialize the prediction database
/// @param appGroupID App group identifier for keyboard extensions (optional)
/// @param completion Called when database is ready
/// @see PredictionKeyboardManager
```

## Submitting Changes

### 1. Push to Your Fork

```bash
git push origin feature/your-feature-name
```

### 2. Open a Pull Request

- Clear title describing the change
- Reference related issues (#123)
- Describe what changed and why
- Mention any breaking changes

**PR Title Example:**
```
feat: add predictive text ranking algorithm

Implements Bayesian scoring for better prediction accuracy.
Fixes #45
```

### 3. Respond to Review

- Respond to all feedback
- Push new commits for revisions (don't force-push)
- Ask for clarification if needed

## Reporting Issues

When reporting bugs, include:

- iOS version and device/simulator
- Steps to reproduce
- Expected vs actual behavior
- Relevant code snippet or stack trace
- CocoaPods version

**Example Issue:**

```
**Description:**
Predictions not appearing after app update

**Environment:**
- iOS 14.5, iPhone 11
- PredictionKeyboard 1.0.0
- CocoaPods 1.11.3

**Steps to Reproduce:**
1. Install pod
2. Initialize manager with app group
3. Enter text in custom keyboard

**Expected:**
Predictions display below keyboard

**Actual:**
No predictions appear (database empty?)
```

## Feature Requests

Describe your proposed feature:

- Use case and motivation
- Expected behavior
- Implementation approach (if known)
- Compatibility concerns

## Project Priorities

Current focus areas:
- Prediction accuracy improvements
- Keyboard extension support
- Memory optimization
- iOS 13+ compatibility

## Dependencies

- **Realm** (~> 10.0): Object database
- **MBProgressHUD** (~> 1.2): Loading indicators
- **Minimum iOS**: 13.0

Changes affecting dependencies should be justified and backwards-compatible when possible.

## Questions?

- Check existing [GitHub Discussions](https://github.com/carloskekwa/PredictionKeyboard/discussions)
- Open an issue for clarification

## License

By contributing, you agree your code will be licensed under [MIT License](LICENSE).

---

Thank you for helping improve PredictionKeyboard! 🎉
