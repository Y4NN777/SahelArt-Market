# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SahelArt-Market is a marketplace for West African (Sahel region) artisan products. It follows a **Contract-First** approach — all behavior must conform to the system contract defined in `docs/sahel_art_system_contract_and_invariants.md`.

## Common Commands

### Backend (from repo root via Makefile)

```bash
make install          # Install backend dependencies
make dev              # Start backend dev server (hot reload, port 3000)
make back-test        # Run backend tests (Jest)
make build            # TypeScript build
make lint             # ESLint
make format           # Prettier write
make typecheck        # TypeScript type checking (tsc --noEmit)
make ci               # lint + test + build pipeline
```

Run a single test file:
```bash
cd backend && npx jest tests/path/to/file.test.ts
```

### Docker

```bash
make up               # Start backend + MongoDB containers
make down             # Stop containers
make logs             # Tail container logs
make db-shell         # mongosh into MongoDB
make shell            # Shell into API container
```

### Frontend (Flutter)

```bash
cd frontend
flutter pub get                    # Install dependencies
flutter pub run build_runner build --delete-conflicting-outputs  # Generate JSON serialization
flutter run -d chrome              # Run web
flutter test                       # Run tests
flutter analyze                    # Lint
```

## Architecture

### Backend — Layered Architecture

**Stack**: Node.js 20 / Express / TypeScript 5.6 / MongoDB 7 (Mongoose 8) / Jest

```
Routes → Middleware Pipeline → Controllers → Services → Repositories → Models → MongoDB
```

**Middleware pipeline order**: CORS/helmet/body-parser → rate limiter → auth (`requireAuth`) → RBAC (`allowRoles`) → ownership check → Joi validation → invariants check

All API routes are prefixed with `/api/v1`. Health check: `GET /api/v1/health`.

Key source paths under `backend/src/`:
- `routes/` — Express route definitions
- `controllers/` — Parse request, delegate to service
- `services/` — Business logic, enforces invariants
- `repositories/` — Thin Mongoose data access layer
- `models/` — Mongoose schemas with indexes
- `middleware/` — Auth, RBAC, validation, error handling, invariants
- `utils/ApiError.ts` — Custom error class with `statusCode`, `code`, `details`
- `utils/asyncHandler.ts` — Wraps async route handlers
- `config/` — Database connection, JWT config, upload config
- `types/` — Shared TypeScript types; `express.d.ts` extends Express Request with `user`

### Frontend — Clean Architecture with Provider

**Stack**: Flutter 3.27+ / Dart / Provider / Dio / go_router

```
presentation/ (screens, widgets, providers) → domain/ (entities, repository interfaces) → data/ (models, repositories, services)
```

- State management via `ChangeNotifier` providers
- `api_service.dart` uses Dio with interceptors (auth token injection, 401 handling)
- Platform-adaptive storage: `flutter_secure_storage` (mobile), `shared_preferences` (web)
- JSON serialization via `json_annotation` + `build_runner`

## Key System Invariants

These are enforced in services and middleware — always respect them:

- **INV-1**: Product stock MUST NOT be negative
- **INV-2**: Order MUST contain ≥1 product
- **INV-3**: Order total MUST equal sum of item subtotals
- **INV-4**: Stock reservation MUST be atomic (MongoDB transactions)
- **INV-5**: Payment amount MUST equal order total
- **INV-6**: Cannot ship unpaid orders

Full invariant list: `docs/sahel_art_system_contract_and_invariants.md`

## Authentication

- JWT access tokens (15min TTL) in `Authorization: Bearer <token>` header
- Refresh tokens (7-day TTL) with SHA256+pepper hashing and rotation
- Roles: `customer`, `vendor`, `admin`
- `RefreshToken` model has TTL index for automatic cleanup

## Conventions

### Commits
Conventional Commits format: `<type>(<scope>): <subject>`
- Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`
- Scopes: `backend`, `frontend`, `api`, `infra`, `dev`

### Branches
- `backend/description` or `frontend/description` — feature branches from `develop`
- PRs target `develop`, not `main`

### Code Style (Backend)
- Strict TypeScript (`strict: true`), no `any`
- Single quotes, semicolons, no trailing commas (`.prettierrc`)
- File structure: external imports → internal imports → types → constants → exports
- Interfaces: `I` prefix (e.g., `IOrder`). Types for unions. Interfaces for objects.
- Error handling: throw `ApiError` for business errors, re-throw known errors, wrap unexpected errors

### Code Style (Frontend)
- Files: `snake_case.dart`. Classes: `PascalCase`. Variables/functions: `camelCase`. Private: `_` prefix.
- Widget structure: final fields → constructor → build() → private helpers

## Key Documentation

- `docs/API.md` — Complete REST API specification (the contract between backend and frontend)
- `docs/ARCHITECTURE.md` — System-level architecture
- `backend/ARCHITECTURE.md` — Detailed backend architecture with code examples
- `frontend/ARCHITECTURE.md` — Flutter architecture with Provider patterns
- `CONTRIBUTING.md` — Full contribution workflow and code standards

## Testing

### Backend Tests

Tests use `mongodb-memory-server` with a replica set for transaction support. No external MongoDB needed.

```bash
make back-test                                    # Run all tests
cd backend && npx jest tests/integration/auth.test.ts  # Run single file
cd backend && npx jest --testPathPattern=unit      # Run only unit tests
```

**Test architecture:**
- `tests/setup.ts` — MongoMemoryReplSet lifecycle, env vars
- `tests/helpers/` — Auth helpers, fixtures, app bootstrap, email mock
- `tests/integration/` — Supertest against full Express app (auth, product, order, payment, category, user, admin)
- `tests/unit/` — Isolated middleware and utility tests

**Test env vars** (set automatically in `tests/setup.ts`):
- `NODE_ENV=test` — disables rate limiter
- `JWT_SECRET`, `REFRESH_TOKEN_PEPPER`, `PAYMENT_WEBHOOK_SECRET` — test values

### Bruno API Collection

Import `bruno/` directory in [Bruno](https://www.usebruno.com/). Select the "local" environment.

Workflow: Register Customer → Register Vendor → List Categories → Create Product → Create Order → Create Payment → Mark Shipped → Mark Delivered. Tokens and IDs auto-chain via post-response scripts.

### Email (Ethereal dev mode)

Leave `SMTP_*` env vars blank for auto-created Ethereal test accounts. Check console for preview URLs.

## Environment

Copy `backend/.env.example` to `backend/.env`. MongoDB requires replica set mode (`rs0`) for transaction support — `docker-compose.yml` handles this automatically.
