# DESIGN SYSTEM — iOS-inspired Solid UI for Quickshell

## 1. Design direction

Create a desktop interface for Quickshell inspired by Apple's iOS design language, adapted for Linux desktop environments.

The visual direction must preserve:
- Apple's visual hierarchy.
- Clean typography.
- Consistent spacing.
- Semantic color usage.
- Native-looking controls.
- Precise alignment.
- Restrained rounded corners.
- Clear interaction states.
- Minimal and intentional compositions.

This is NOT a Liquid Glass implementation.

The final result must use solid, opaque surfaces and must never depend on background blur or transparency to achieve its appearance.

## 2. Absolute visual restrictions

NEVER use:
- Liquid Glass.
- Glassmorphism.
- Backdrop blur.
- Background blur.
- Frosted glass.
- Translucent panel backgrounds.
- Decorative gradients.
- Distortion or refraction effects.
- Strong drop shadows.
- Excessive floating cards.
- Excessive rounded corners.
- Decorative visual effects without a functional purpose.

All panels, menus, popups, dialogs and surfaces must have opaque backgrounds.

Use subtle solid borders to establish separation and hierarchy.

## 3. Color system

### Dark theme

Backgrounds:
- background-primary: #000000
- background-secondary: #1C1C1E
- background-tertiary: #2C2C2E
- background-elevated: #3A3A3C

Labels:
- label-primary: #FFFFFF
- label-secondary: #EBEBF5
- label-tertiary: #8E8E93
- label-disabled: #636366

Separators:
- separator: #38383A

Accent colors:
- blue: #0A84FF
- green: #30D158
- red: #FF4245
- orange: #FF9230
- yellow: #FFD600
- purple: #DB34F2
- teal: #00D2E0

### Light theme

Backgrounds:
- background-primary: #FFFFFF
- background-secondary: #F2F2F7
- background-tertiary: #E5E5EA

Labels:
- label-primary: #000000
- label-secondary: #3C3C43
- label-tertiary: #8E8E93

Separators:
- separator: #C6C6C8

Accent colors:
- blue: #007AFF
- green: #34C759
- red: #FF383C
- orange: #FF8D28
- yellow: #FFCC00
- purple: #CB30E0
- teal: #00C3D0

Use semantic tokens instead of hardcoding colors inside components.

## 4. Typography

Preferred font: Inter.

Fallback: Noto Sans.

Use these typography sizes:

- LargeTitle: 34px / Bold
- Title1: 28px / Bold
- Title2: 22px / Bold
- Title3: 20px / Semibold
- Headline: 17px / Semibold
- Body: 17px / Regular
- Callout: 16px / Regular
- Subheadline: 15px / Regular
- Footnote: 13px / Regular
- Caption1: 12px / Regular
- Caption2: 11px / Regular

Avoid unnecessary font weights and inconsistent typography.

## 5. Dimensions and spacing

Use a consistent 4px spacing system.

- xsmall: 4px
- small: 8px
- medium: 12px
- large: 16px
- xlarge: 24px
- xxlarge: 32px

Corner radii:
- small: 6px
- control: 9px
- panel: 12px
- dialog: 16px

Borders:
- Standard border: 1px
- Use low-contrast solid borders.
- Avoid excessive outlines.

Shadows:
- Prefer no shadows.
- If necessary, use a subtle shadow only for genuine elevation.

## 6. Components

Build reusable QML components for:

### Buttons
- PrimaryButton
- SecondaryButton
- BorderedButton
- BorderlessButton
- DestructiveButton
- IconButton

States:
- Default
- Hover
- Pressed
- Disabled

### Controls
- Switch
- Slider
- Stepper
- SegmentedControl
- TextField
- SearchField

### Surfaces
- Panel
- Popup
- Dialog
- ContextMenu
- Tooltip

### Navigation
- TabBar
- Sidebar
- Toolbar

### Feedback
- Badge
- ProgressIndicator
- Notification
- Alert
- EmptyState

All components must support both dark and light themes where applicable.

## 7. Surface design

Panels must use opaque colors.

Dark theme:
- Main background: #000000
- Secondary surface: #1C1C1E
- Elevated surface: #2C2C2E

Light theme:
- Main background: #F2F2F7
- Secondary surface: #FFFFFF
- Elevated surface: #FFFFFF

Use borders and spacing instead of blur or transparency.

Avoid wrapping every group of content in a card. Use visual grouping, alignment and separators when appropriate.

## 8. Interaction and animation

Animations must be short and functional.

Recommended:
- Hover transitions: 100–150ms
- Press feedback: 80–120ms
- Popup transitions: 150–200ms

Avoid excessive movement, bouncing and decorative animations.

All interactive controls must have clear hover, pressed, selected and disabled states.

## 9. Quickshell implementation

Use native Quickshell and QtQuick components.

Requirements:
- Modular QML architecture.
- Reusable components.
- Shared theme tokens.
- No duplicated visual styles.
- Keep visual components separate from system services.
- Avoid unnecessary timers and expensive bindings.
- Preserve responsiveness and low resource consumption.

Use Context7 to verify Quickshell and QtQuick APIs before implementing unfamiliar functionality.

## 10. Design workflow

Before implementing a new module:

1. Understand its purpose and required interactions.
2. Inspect existing components and theme tokens.
3. Identify the relevant components from this design system.
4. Propose the layout and visual hierarchy.
5. Explain dimensions, spacing and interaction states.
6. Implement the approved design.
7. Review screenshots and fix alignment, proportions and visual inconsistencies.

Do not generate generic AI dashboards.

Do not automatically use cards, gradients or floating panels.

Every visual element must have a clear functional purpose.

## 11. Final quality criteria

The interface must feel:
- Native.
- Precise.
- Consistent.
- Minimal.
- Professional.
- Responsive.
- Visually balanced.

The result should look like a carefully designed desktop operating system interface inspired by iOS, not a web dashboard or a Liquid Glass clone.
