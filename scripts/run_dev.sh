#!/bin/bash
set -euo pipefail

# Carrega chaves de .env.local (não versionado)
if [ -f .env.local ]; then
  # shellcheck disable=SC1091
  source .env.local
fi

DART_DEFINES=(
  "--dart-define=REVENUECAT_APPLE_API_KEY=${REVENUECAT_APPLE_API_KEY:-}"
  "--dart-define=REVENUECAT_GOOGLE_API_KEY=${REVENUECAT_GOOGLE_API_KEY:-}"
  "--dart-define=SENTRY_DSN=${SENTRY_DSN:-}"
  "--dart-define=POSTHOG_API_KEY=${POSTHOG_API_KEY:-}"
  "--dart-define=POSTHOG_HOST=${POSTHOG_HOST:-https://us.i.posthog.com}"
  "--dart-define=POSTHOG_DEBUG=${POSTHOG_DEBUG:-true}"
  "--dart-define=SUPABASE_URL=${SUPABASE_URL:-}"
  "--dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY:-}"
  "--dart-define=AI_PROXY_URL=${AI_PROXY_URL:-}"
  "--dart-define=OPENAI_API_KEY=${OPENAI_API_KEY:-}"
  "--dart-define=OPENAI_MODEL=${OPENAI_MODEL:-gpt-4o-mini}"
)

echo "Iniciando toDoin com dart-defines de .env.local..."
flutter run "${DART_DEFINES[@]}" "$@"
