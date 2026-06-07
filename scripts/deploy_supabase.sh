#!/bin/bash
set -euo pipefail

# Deploy Supabase (schema remoto + Edge Function suggest-subtasks)
# Pré-requisitos: brew install supabase/tap/supabase, supabase login, supabase link

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v supabase >/dev/null 2>&1; then
  echo "Instale o CLI: brew install supabase/tap/supabase"
  exit 1
fi

if [ -f .env.local ]; then
  # shellcheck disable=SC1091
  source .env.local
fi

echo "==> Aplicando migrations no projeto linkado..."
supabase db push

echo "==> Configurando secrets da Edge Function (se definidos em .env.local)..."
if [ -n "${OPENAI_API_KEY:-}" ]; then
  supabase secrets set "OPENAI_API_KEY=${OPENAI_API_KEY}"
fi
if [ -n "${OPENAI_MODEL:-}" ]; then
  supabase secrets set "OPENAI_MODEL=${OPENAI_MODEL}"
fi

echo "==> Deploy suggest-subtasks (JWT verification ativo)..."
supabase functions deploy suggest-subtasks

echo ""
echo "Deploy concluído."
echo "Confirme no .env.local:"
echo "  AI_PROXY_URL=https://jcqhcltldwkfektodmzl.supabase.co/functions/v1/suggest-subtasks"
echo ""
echo "Dashboard: Authentication → Anonymous Sign-ins = ON"
