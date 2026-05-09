# HN Reader — Flutter Assignment

A Hacker News reader app built with Flutter.

## Features

- **Home screen**: Lists top 500 HN stories with infinite scroll (20 per page)
- **Detail screen**: Story header + first-level comments with nested replies
- **Bonus**: Nested comments auto-load to depth 2; deeper levels load on tap
- **Pull-to-refresh** on home screen
- **Open article** in browser from detail screen

## Architecture

```
lib/
├── main.dart
├── models/
│   └── hn_item.dart          # Single model for stories & comments
├── repositories/
│   └── hn_repository.dart    # All HN API calls
├── cubits/
│   ├── stories/
│   │   ├── stories_cubit.dart
│   │   └── stories_state.dart
│   └── detail/
│       ├── detail_cubit.dart
│       └── detail_state.dart
├── screens/
│   ├── home_screen.dart
│   └── detail_screen.dart
├── widgets/
│   ├── story_tile.dart       # List row widget
│   └── comment_widget.dart   # Recursive nested comment widget
└── utils/
    └── time_utils.dart
```

**State management**: flutter_bloc (Cubit)  
**Networking**: http  
**HTML rendering**: flutter_html (for comment text)  
**Time formatting**: timeago  

## Setup

```bash
flutter pub get
flutter run
```

Requires Flutter 3.x and Dart SDK >=3.0.0.

## APIs used

- `GET https://hacker-news.firebaseio.com/v0/topstories.json` — list of story IDs
- `GET https://hacker-news.firebaseio.com/v0/item/{id}.json` — story/comment detail
