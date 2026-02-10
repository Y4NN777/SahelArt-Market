# SahelArt - Backend Makefile
# ===========================

SHELL := /bin/bash

BACKEND_DIR := backend
COMPOSE_FILE := docker-compose.yml

.PHONY: help install back-run back-test dev

# ============================================
# 📋 HELP
# ============================================

help:
	@echo ""
	@echo "╔══════════════════════════════════════════════════════════════╗"
	@echo "║              🚀 SahelArt - Backend Commands                  ║"
	@echo "╚══════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📦 BACKEND (sans Docker):"
	@echo "  make install        - Installer les dépendances"
	@echo "  make dev            - Lancer le backend (dev mode)"
	@echo "  make back-test      - Lancer les tests backend"
	@echo "  make build          - Build backend"
	@echo "  make start          - Démarrer backend (prod build)"
	@echo "  make lint           - ESLint"
	@echo "  make format         - Prettier write"
	@echo "  make format-check   - Prettier check"
	@echo "  make typecheck      - TypeScript typecheck"
	@echo "  make ci             - lint + test + build"
	@echo ""
	@echo "🐳 DOCKER BACKEND:"
	@echo "  make up             - Démarrer backend + mongo"
	@echo "  make down           - Arrêter Docker"
	@echo "  make build-docker   - Construire les images"
	@echo "  make logs           - Voir les logs"
	@echo "  make ps             - Voir les containers"
	@echo "  make test           - Tester l'endpoint health"
	@echo "  make clean          - Supprimer tout (⚠️ destructif)"
	@echo "  make shell          - Shell dans le container api"
	@echo "  make db-shell       - mongosh dans mongo"
	@echo ""

# ============================================
# 📦 BACKEND (sans Docker)
# ============================================

install:
	cd $(BACKEND_DIR) && npm install

dev:
	cd $(BACKEND_DIR) && npm run dev

back-test:
	cd $(BACKEND_DIR) && npm test

build:
	cd $(BACKEND_DIR) && npm run build

start:
	cd $(BACKEND_DIR) && npm run start

lint:
	cd $(BACKEND_DIR) && npm run lint

format:
	cd $(BACKEND_DIR) && npm run format

format-check:
	cd $(BACKEND_DIR) && ./node_modules/.bin/prettier --check "src/**/*.ts"

typecheck:
	cd $(BACKEND_DIR) && ./node_modules/.bin/tsc -p tsconfig.json --noEmit

ci: lint back-test build

# ============================================
# 🐳 DOCKER BACKEND
# ============================================

.PHONY: up down build-docker logs ps test clean shell db-shell rebuild

up:
	@echo "🚀 Démarrage de SahelArt (backend) dans Docker..."
	docker compose -f $(COMPOSE_FILE) up -d
	@echo ""
	@echo "✅ Backend démarré!"
	@echo "   Health: http://localhost:3000/api/health"
	@echo ""


down:
	@echo "🛑 Arrêt de SahelArt..."
	docker compose -f $(COMPOSE_FILE) down
	@echo "✅ Arrêté."

build-docker:
	@echo "🏗️  Construction des images Docker..."
	docker compose -f $(COMPOSE_FILE) build
	@echo "✅ Construction terminée."

rebuild:
	@echo "🔄 Reconstruction complète (sans cache)..."
	docker compose -f $(COMPOSE_FILE) build --no-cache
	docker compose -f $(COMPOSE_FILE) up -d
	@echo "✅ Rebuild terminé!"

logs:
	docker compose -f $(COMPOSE_FILE) logs -f

ps:
	@echo "📦 Containers en cours d'exécution:"
	@docker compose -f $(COMPOSE_FILE) ps

test:
	@echo "🏥 Test de l'endpoint health..."
	@echo -n "Backend:  "
	@curl -s http://localhost:3000/api/health 2>/dev/null | grep -q "ok" && echo "✅ Healthy" || echo "❌ Down"
	@echo ""

clean:
	@echo "🧹 Nettoyage Docker..."
	@echo "⚠️  Ceci va supprimer tous les containers et volumes!"
	@read -p "Continuer? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker compose -f $(COMPOSE_FILE) down -v; \
		docker system prune -f; \
		echo "✅ Nettoyage terminé."; \
	else \
		echo "❌ Annulé."; \
	fi

shell:
	docker compose -f $(COMPOSE_FILE) exec api sh

db-shell:
	docker compose -f $(COMPOSE_FILE) exec mongo mongosh
