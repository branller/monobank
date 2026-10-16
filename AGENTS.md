# Monopoly Bank — Agent Rules

## Project
- Build an offline-first Monopoly banking app using Flutter and Dart.
- Android is the initial target.
- Use NFC cards only to identify players. Balances and transactions are stored locally on the phone.
- Do not add a backend, networking, or property management unless explicitly requested.
- User-facing text must be in Spanish. Code identifiers must be in English.

## Principles
- Follow Clean Code, SOLID when appropriate, and KISS.
- Prefer simple, readable, maintainable solutions.
- Make the smallest change that fully solves the requested task.
- Do not implement unrequested features or abstractions.
- Avoid duplicated logic, magic values, dead code, and unnecessary dependencies.

## Architecture
- Organize code by feature under `lib/features/`.
- Separate `domain/`, `data/`, and `presentation/` when justified.
- Keep domain logic independent of Flutter, storage, and NFC packages.
- Define repository contracts in the domain and implementations in the data layer.
- Presentation must not depend directly on concrete data implementations.
- Use `lib/core/` only for genuinely shared code.
- Do not create empty folders or layers before they are needed.

## Flutter and Dart
- Follow official Dart style and idiomatic Flutter practices.
- Use null safety, immutable models where practical, and `const` where appropriate.
- Keep business logic out of widgets.
- Add packages only when necessary and explain why.

## Banking integrity
- Treat balances and transactions as domain logic, not UI logic.
- Keep balances and transaction history locally.
- Ensure transfers update all affected balances consistently.
- Never silently invent, discard, or overwrite financial data.

## Workflow
- Inspect relevant files before modifying them.
- Preserve existing working behavior and avoid rewriting entire files unnecessarily.
- Ask one concise question if an ambiguity affects architecture or data integrity.
- Do not run commands, tests, builds, `flutter analyze`, or formatters unless explicitly requested.
- Check modified code for obvious issues without running commands.
- Report changed files, important decisions, and manual validation steps in no more than 5 lines.
- Work on one task at a time and stop when the requested task is complete.

## Token efficiency
- Keep prompts, explanations, and reports concise.
- Do not repeat context already documented here.
- Avoid unnecessary file reads, broad refactoring, and repeated verification.
