# TermiAr - Your Linux Command Companion

A comprehensive, bilingual (Arabic/English) Flutter application for learning Linux commands with a Zorin OS aesthetic.

## Features

### 🎯 Core Features
- **📱 Bilingual Interface**: Full Arabic/English support throughout the app
- **🔍 Real-time Search**: Instantly find any command from the comprehensive database
- **📚 Organized Categories**: Commands grouped by functionality (Universal, File Management, Networking, etc.)
- **🎨 Zorin OS Inspired Design**: Clean, modern interface with Zorin Blue (#0055FF) color scheme
- **🌓 Dynamic Theme Switching**: Beautiful light and dark modes with smooth transitions
- **📋 Copy to Clipboard**: Quick copy functionality for all commands
- **🎯 Interactive Quiz Mode**: Test your Linux knowledge with engaging quizzes
- **💡 Daily Tips**: Learn new tricks and best practices daily
- **📱 Responsive Design**: Optimized for various screen sizes

### 🛠️ Technical Implementation
- **State Management**: Provider pattern for efficient state handling
- **Data Models**: JSON-based architecture with automatic serialization
- **Navigation**: Bottom navigation bar with 4 main sections
- **Asset Management**: Structured JSON data files for easy content updates

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                  # Data models
│   ├── category_model.dart
│   ├── command_model.dart
│   └── quiz_model.dart
├── providers/                # State management
│   └── theme_provider.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── main_navigation.dart
│   ├── categories_screen.dart
│   ├── category_commands_screen.dart
│   ├── command_details_screen.dart
│   ├── quiz_screen.dart
│   └── about_screen.dart
├── services/                 # Business logic
│   └── data_service.dart
└── widgets/                  # Reusable components
    └── daily_tip_card.dart

assets/
├── data/                    # JSON data files
│   ├── categories.json
│   ├── commands_bank.json
│   └── learning_quiz.json
└── images/                  # App images and logos
```

## Getting Started

### Prerequisites
- Flutter SDK (>=3.10.4)
- Dart SDK
- Android Studio / VS Code with Flutter extension

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

### Dependencies
- `provider`: State management
- `json_annotation` & `json_serializable`: JSON serialization
- `shared_preferences`: Theme persistence
- `google_fonts`: Typography
- `flutter_staggered_grid_view`: UI layouts
- `flutter_svg`: SVG support

## Data Structure

### Categories (`categories.json`)
```json
{
  "categories": [
    {
      "id": "universal",
      "name_ar": "أوامر مشتركة (Universal)",
      "name_en": "Universal Commands",
      "icon": "terminal",
      "description": "الأوامر التي تعمل على جميع توزيعات لينكس بلا استثناء."
    }
  ]
}
```

### Commands (`commands_bank.json`)
```json
{
  "commands": [
    {
      "id": 1,
      "category_id": "universal",
      "command": "ls",
      "syntax": "ls [options]",
      "level": "مبتدئ",
      "name_ar": "عرض الملفات",
      "description": "يعرض قائمة بالملفات والمجلدات الموجودة في المسار الحالي.",
      "how_to_use": "اكتب 'ls' لرؤية الملفات العادية، أو 'ls -a' لرؤية الملفات المخفية.",
      "can_copy": true
    }
  ]
}
```

### Quiz & Tips (`learning_quiz.json`)
```json
{
  "questions": [...],
  "daily_tips": [...]
}
```

## UI/UX Design

### Theme System
- **Light Mode**: Clean white background with Zorin Blue accents
- **Dark Mode**: Dark slate grays with blue highlights
- **Dynamic Switching**: Theme preference persisted using SharedPreferences

### Color Palette
- **Primary**: #0055FF (Zorin Blue)
- **Background**: Light: White, Dark: #1A1A1A
- **Surface**: Light: Grey shades, Dark: #2A2A2A
- **Accent**: Consistent blue throughout the interface

### Typography
- Google Fonts integration for optimal readability
- Proper Arabic RTL support
- Hierarchical text sizing for better UX

## Key Features Deep Dive

### Search Functionality
- Real-time filtering as you type
- Searches through command names, descriptions, and syntax
- Displays difficulty levels with color coding
- Quick navigation to command details

### Command Details
- Complete command information display
- Syntax highlighting in monospace font
- Copy buttons for easy clipboard access
- Bilingual descriptions and usage examples

### Quiz System
- Multiple choice questions with immediate feedback
- Score tracking and progress indication
- Detailed explanations for learning
- Sample questions for continuous engagement

### Daily Tips
- Rotating tips based on current day
- Category-specific tips for targeted learning
- Visually appealing card design
- Skip functionality for user control

## Development Guidelines

### Adding New Commands
1. Update `commands_bank.json` with new command entries
2. Ensure proper category assignment
3. Include comprehensive Arabic/English descriptions
4. Test search functionality
5. Verify copy functionality

### Adding New Categories
1. Update `categories.json` with new category data
2. Choose appropriate Material Design icons
3. Provide bilingual names and descriptions
4. Update icon mapping in home screen

### Extending Quiz Content
1. Add questions to `learning_quiz.json`
2. Follow the established structure
3. Include explanations for learning
4. Maintain difficulty balance

## Future Enhancements

### Planned Features
- [ ] Command execution simulation
- [ ] Advanced filtering options
- [ ] Favorites/bookmarking system
- [ ] Progress tracking and achievements
- [ ] Community contributions
- [ ] Command chaining builder
- [ ] Offline mode optimization
- [ ] Voice search support

### Performance Optimizations
- [ ] Lazy loading for large command sets
- [ ] Image optimization for faster loading
- [ ] Memory usage optimization
- [ ] Battery usage improvements

## Contributing

We welcome contributions! Please ensure:
- Proper code formatting and documentation
- Bilingual content updates
- Testing on multiple screen sizes
- Following Flutter best practices

## License

This project is open source. See LICENSE file for details.

---

**Built with ❤️ using Flutter for the Linux community**
