# Data Layer

Implements repositories and handles API/Hive communication.

- **models/** — JSON-serializable data models (extends entities)
- **repositories/** — Concrete repository implementations
- **datasources/remote/** — HTTP clients for MusicBrainz, Last.fm, Genius, Cover Art Archive
- **datasources/local/** — Hive database operations

See [Architecture Guide](../../README.md#project-structure) for details.
