# SahelArt Backend

API REST pour SahelArt (Node.js + Express + TypeScript + MongoDB).

## Prérequis
- Node.js 20+
- MongoDB 7+

## Installation
```bash
cd backend
npm install
cp .env.example .env
```

## Démarrage
```bash
npm run dev
```

API disponible sur `http://localhost:3000/api`.

## Docker
Depuis la racine du repo :
```bash
docker compose up --build
```

Le `docker-compose.yml` configure MongoDB en replica set pour supporter les transactions.

## Endpoints rapides
- `GET /api/health`
- `POST /api/auth/register`
- `POST /api/auth/login`
- `POST /api/auth/refresh`
- `POST /api/auth/logout`

## Notes
- Access token (JWT) dans le body.
- Refresh token dans le body + cookie HTTP-only `refresh_token`.
