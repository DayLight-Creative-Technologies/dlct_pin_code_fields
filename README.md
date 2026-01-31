<p align="center">
  <img width="460" src="https://i.ibb.co/X5qxF7x/export-banner.png">
</p>

<a href="https://pub.dev/packages/pin_code_fields"><img src="https://img.shields.io/pub/v/pin_code_fields"></a>

# Pin Code Fields

A highly customizable Flutter package for PIN code and OTP input fields with beautiful design and animations.

**Version 9.0** introduces a new **headless architecture** - use the ready-made Material Design implementation or build completely custom UIs!

## Package Location

The publishable package is located at:

```
packages/pin_code_fields/
```

📦 **[View Package README](packages/pin_code_fields/README.md)** for full documentation.

## Quick Start

```yaml
dependencies:
  pin_code_fields: ^9.0.0
```

```dart
import 'package:pin_code_fields/pin_code_fields.dart';

// Material Design (ready to use)
MaterialPinField(
  length: 6,
  onCompleted: (pin) => print('PIN: $pin'),
)

// Custom UI (headless)
PinInput(
  length: 4,
  builder: (context, cells) => YourCustomUI(cells),
)
```

## Repository Structure

```
pin_code_fields/
├── packages/
│   └── pin_code_fields/      # 📦 Main package
│       ├── lib/
│       │   └── src/
│       │       ├── core/     # Headless input engine
│       │       └── material/ # Material Design implementation
│       ├── example/
│       ├── test/
│       ├── README.md
│       ├── CHANGELOG.md
│       └── LICENSE
├── docs/
│   └── FEATURE_COMPARISON.md
├── melos.yaml
└── CLAUDE.md
```

## Development

This project uses [melos](https://melos.invertase.dev/) for monorepo management.

```bash
# Install melos
dart pub global activate melos

# Bootstrap workspace
melos bootstrap

# Run tests
melos test

# Run analyzer
melos analyze
```

## Features

- 🎨 **Headless Architecture** - Full control over UI rendering
- 📱 **Material Design Ready** - Beautiful out-of-the-box implementation
- 🎮 **Unified Controller** - Single controller for text, focus, and errors
- ✨ **Rich Animations** - Scale, fade, slide entry animations
- 🔐 **Obscure Support** - Character or custom widget obscuring
- 📋 **Paste Support** - Long-press to paste from clipboard
- 📝 **Form Integration** - Works with Flutter's Form widget
- 📲 **Autofill Support** - SMS OTP autofill for iOS/Android
- 💫 **Error Animation** - Shake animation with programmatic control

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see [LICENSE](packages/pin_code_fields/LICENSE) for details.
