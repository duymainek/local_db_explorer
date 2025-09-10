# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of local_db_explorer package
- Core `DBAdapter` abstract class for extensible database support
- `SqfliteAdapter` with full read/write support for SQLite databases
- `HiveAdapter` stub implementation (ready for extension)
- `SharedPreferencesAdapter` stub implementation (ready for extension)
- `DBViewer` controller class with navigation management
- `InspectorScreen` full-screen UI with mobile-optimized design
- Debug-only operation for security (no-op in release builds)
- Navigation-based approach using standard Flutter patterns
- Responsive design that adapts to portrait/landscape orientation
- Tabbed interface for multiple database adapters
- Collection dropdown/sidebar with automatic discovery
- Card-based data view optimized for mobile
- Paginated data display with search and filtering
- Full-screen record detail viewer with JSON formatting
- Full-screen record editor with JSON validation
- Record deletion with confirmation dialogs
- Copy to clipboard functionality
- Comprehensive example apps with multiple database types
- Full documentation and API reference

### Features
- **Multi-database support**: Register multiple adapters simultaneously
- **Real-time search**: Filter records as you type
- **Pagination**: Handle large datasets efficiently
- **CRUD operations**: View, edit, and delete records (where supported)
- **JSON formatting**: Pretty-print complex data structures
- **Error handling**: Graceful error handling with user feedback
- **Mobile-first design**: Optimized for mobile devices with responsive layout
- **Accessibility**: Proper semantic markup and keyboard navigation

### Security
- All functionality disabled in release builds (`kDebugMode` check)
- No network access or data persistence
- Local-only operation within the app
- Standard Flutter navigation implementation