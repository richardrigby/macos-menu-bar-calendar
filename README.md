# macOS Menu Bar Calendar

A minimalist Swift-built macOS menu bar calendar application that displays the current date in the menu bar and provides a quick-access calendar popover.

## Features

- **Menu Bar Display**: Shows the current day number in the menu bar
- **Calendar Icon Option**: Toggle between a simple day number or a stylized calendar icon
- **Popover Calendar**: Click the menu bar item to view a full calendar with month navigation
- **Customizable Settings**:
  - Choose first day of the week (Sunday or Monday)
  - Toggle calendar icon vs. day number display
  - Show/hide week numbers
- **System Integration**: Runs as a background app with no dock icon
- **Automatic Updates**: Refreshes the date display at midnight

## Screenshots

Add screenshots here showing the menu bar icon and popover

## Requirements

- macOS 12.0 or later
- Xcode 14.0 or later
- Swift 5.7 or later

## Installation

### Option 1: Download Pre-built App

1. Download the latest release from the [Releases](https://github.com/richardrigby/macos-menu-bar-calendar/releases) page
2. Unzip the downloaded file
3. Move `MenuBarCalendar.app` to your Applications folder
4. Launch the app from Applications or Spotlight

### Option 2: Build from Source

1. Clone this repository:

   ```bash
   git clone https://github.com/richardrigby/macos-menu-bar-calendar.git
   cd macos-menu-bar-calendar
   ```

2. Open the project in Xcode:

   ```bash
   open MenuBarCalendar.xcodeproj
   ```

3. Build and run the project:
   - Select the `MenuBarCalendar` scheme
   - Press `Cmd + R` to build and run

## Usage

### First Launch

- The app will appear in your menu bar as a day number (e.g., "28")
- No dock icon will be visible (this is intentional for menu bar apps)

### Accessing the Calendar

1. Click the day number in the menu bar
2. A popover will appear showing the current month's calendar
3. Navigate between months using the arrow buttons
4. Click on any date to highlight it (for reference)

### Settings

1. Click the gear icon (⚙️) in the calendar popover
2. Or right-click the menu bar icon and select "Settings"
3. Configure your preferences:
   - **First Day of Week**: Choose whether weeks start on Sunday or Monday
   - **Use Calendar Icon**: Toggle between calendar icon and plain day number
   - **Show Week Numbers**: Display ISO week numbers in the calendar

### Quitting the App

- Right-click the menu bar icon
- Select "Quit Menu Bar Calendar"

## Project Structure

```text
macos-menu-bar-calendar/
├── MenuBarCalendar/           # Main app source code
│   ├── AppDelegate.swift      # App lifecycle and menu bar management
│   ├── MenuBarCalendarApp.swift # SwiftUI app entry point
│   ├── CalendarView.swift     # Calendar popover UI
│   ├── SettingsView.swift     # Settings window UI
│   ├── SettingsManager.swift  # User preferences management
│   ├── Info.plist            # App configuration
│   └── Assets.xcassets/      # App icons and assets
├── MenuBarCalendar.xcodeproj/ # Xcode project files
├── generate_icon.swift        # Icon generation script
├── LICENSE                   # CC0 1.0 Universal license
└── README.md                 # This file
```

## Development

### Building the Project

1. Ensure you have Xcode installed
2. Open `MenuBarCalendar.xcodeproj`
3. Select a target device/simulator
4. Build with `Cmd + B` or run with `Cmd + R`

### Icon Generation

The app includes a Swift script to generate calendar icons:

```bash
swift generate_icon.swift
```

This script creates various sizes of calendar icons for the app icon set.

### Code Style

- Follows Swift standard naming conventions
- Uses SwiftUI for the user interface
- Implements MVVM architecture where applicable
- Settings are persisted using UserDefaults

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -am 'Add some feature'`
5. Push to the branch: `git push origin feature/your-feature-name`
6. Submit a pull request

### Areas for Contribution

- Additional calendar themes
- Localization support
- Calendar event integration
- Custom date formatting options
- Accessibility improvements

## Troubleshooting

### App Not Appearing in Menu Bar

- Check if the app is running in Activity Monitor
- Restart the app
- Ensure no other apps are conflicting with menu bar space

### Settings Not Saving

- Check UserDefaults permissions
- Try resetting settings by deleting the app's preferences:

  ```bash
  defaults delete com.yourbundleidentifier.MenuBarCalendar
  ```

### Build Issues

- Ensure you're using a compatible Xcode version
- Clean the build folder: `Cmd + Shift + K`
- Update Swift Package dependencies if needed

## License

This project is released under the [CC0 1.0 Universal](LICENSE) license, placing it in the public domain. You can use, modify, and distribute this code without any restrictions.

## Acknowledgments

- Built with SwiftUI and AppKit
- Inspired by minimalist calendar applications
- Uses system calendar calculations for accuracy

## Support

If you encounter issues or have questions:

1. Check the [Issues](https://github.com/richardrigby/macos-menu-bar-calendar/issues) page
2. Create a new issue with detailed information
3. Include your macOS version, Xcode version, and steps to reproduce

---

**Version**: 1.0  
**Last Updated**: November 2025
