# toDoin — Implementações pendentes (passo a passo)

Última atualização: 8 jun 2026.

> **Rodar o app com todas as chaves:** `./scripts/run_dev.sh` (lê `.env.local` automaticamente)

### Supabase + AI — concluído neste projeto

| Etapa | Status |
|-------|--------|
| Projeto linkado (`jcqhcltldwkfektodmzl`) | ✅ |
| Migration `app_sync_v2` (produção) | ✅ `supabase db push` |
| Remoção tabela legada `app_sync` | ✅ migration `20260608120000_drop_legacy_app_sync.sql` |
| Edge Function `suggest-subtasks` (JWT ativo) | ✅ deploy com `supabase functions deploy` |
| CI GitHub Actions (`flutter analyze` + `test`) | ✅ `.github/workflows/flutter_ci.yml` |
| Secrets `OPENAI_API_KEY` + `OPENAI_MODEL` | ✅ |
| Auth anônima (signup) | ✅ validado via API |
| `AI_PROXY_URL` no `.env.local` | ✅ |
| Script `./scripts/deploy_supabase.sh` | ✅ |

Validação rápida:

```bash
curl -X POST "$AI_PROXY_URL" \
  -H "Content-Type: application/json" \
  -H "apikey: $SUPABASE_ANON_KEY" \
  -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
  -d '{"taskTitle":"Estudar Flutter","taskType":"study"}'
# → {"subtasks":["...","...","..."]}
```

Após atualizar o código, rode no Supabase linkado:

```bash
./scripts/deploy_supabase.sh   # aplica drop de app_sync + redeploy da function
```

---

## Configuração de produto pendente (não é código)

Estas etapas exigem painéis externos. O código já está pronto — falta configurar nas lojas.

| O quê | Onde está o passo a passo |
|-------|---------------------------|
| **App Store Connect** (criar app, metadados, screenshots, IAP) | [`CONFIGURACAO_LANCAMENTO.md` §2.1, §4](CONFIGURACAO_LANCAMENTO.md) |
| **Google Play Console** (criar app, Data safety, IAP) | [`CONFIGURACAO_LANCAMENTO.md` §2.2, §5](CONFIGURACAO_LANCAMENTO.md) |
| **RevenueCat** (produtos, entitlement `pro`, sandbox) | [`CONFIGURACAO_LANCAMENTO.md` §3](CONFIGURACAO_LANCAMENTO.md) |
| **Widget iOS no Xcode** (validar build) | [`CONFIGURACAO_LANCAMENTO.md` §6.3](CONFIGURACAO_LANCAMENTO.md) + [`ios/TodoinExtensions/README.md`](../ios/TodoinExtensions/README.md) |
| **App Group iOS** (Widget + Live Activity) | [`CONFIGURACAO_LANCAMENTO.md` §6.2](CONFIGURACAO_LANCAMENTO.md) |
| **Keystore Android** (release assinado) | [`CONFIGURACAO_LANCAMENTO.md` §5.2, §7.1](CONFIGURACAO_LANCAMENTO.md) |
| **URLs legais** (privacidade/termos) | [`CONFIGURACAO_LANCAMENTO.md` §9.1](CONFIGURACAO_LANCAMENTO.md) |
| **Build release** (todas as dart-defines) | [`CONFIGURACAO_LANCAMENTO.md` §10](CONFIGURACAO_LANCAMENTO.md) + `./scripts/build_release.sh` |

### Widget iOS — resumo rápido (Xcode)

Target unificado: `ios/TodoinExtensions/` (Home Widget + Live Activity).

1. `open ios/Runner.xcworkspace`
2. Confirme target **TodoinExtensionsExtension** → pasta `TodoinExtensions/`
3. **Signing & Capabilities** → App Groups → `group.com.cubitapp.todoinapp`
4. Bundle ID: `com.cubitapp.todoinapp.TodoinExtensions`
5. Build & adicionar widget **toDoin** na home do simulador (usuário Pro)

Detalhes: [`ios/TodoinExtensions/README.md`](../ios/TodoinExtensions/README.md)

### App Store — resumo rápido

1. Criar app em App Store Connect (`com.cubitapp.todoinapp`)
2. Configurar IAP (§3.3 do guia de lançamento)
3. Screenshots 6.7" e 6.1"
4. Certificado Distribution + Provisioning Profile no Xcode (§4.5)
5. `flutter build ipa` ou `./scripts/build_release.sh`
6. Upload via Transporter → TestFlight → revisão

Detalhes: [`CONFIGURACAO_LANCAMENTO.md` §4](CONFIGURACAO_LANCAMENTO.md)

### Google Play — resumo rápido

1. Criar app na Play Console
2. Keystore + `android/key.properties`
3. Produtos de assinatura (mesmos IDs do código)
4. `./scripts/build_release.sh` → upload `.aab`
5. Internal testing → produção

Detalhes: [`CONFIGURACAO_LANCAMENTO.md` §5](CONFIGURACAO_LANCAMENTO.md)

---

## Status do que já está no código


| Feature                         | Status código    | Config externa necessária   |
| ------------------------------- | ---------------- | --------------------------- |
| PostHog analytics               | ✅                | `POSTHOG_API_KEY`           |
| Sentry crashes                  | ✅                | `SENTRY_DSN`                |
| RevenueCat billing              | ✅                | Dashboard + chaves loja     |
| Backup JSON local (Pro)         | ✅                | —                           |
| **Cloud Sync Supabase (Pro)**   | ✅                | — (projeto configurado)     |
| **LLM subtarefas OpenAI (Pro)** | ✅                | — (`AI_PROXY_URL` + secrets)|
| Widget Android                  | ✅                | —                           |
| Widget iOS                      | ✅                | Validar build no simulador  |
| Live Activity iOS               | ✅                | Dispositivo físico          |
| Android release signing         | ⚠️ Gradle pronto | `key.properties` + keystore |
| URLs legais                     | ✅ Notion        | Email `suporte@todoin.app`  |


---

## 1. Cloud Sync (Supabase) — ✅ configurado

> Projeto `jcqhcltldwkfektodmzl` com migrations aplicadas e auth anônima ativa.

### 1.1 Re-deploy (se alterar schema ou function)

```bash
./scripts/deploy_supabase.sh
```

### 1.2 Validar no app (Pro)

1. Ative Pro (sandbox RevenueCat ou modo dev).
2. **Configurações → Sync automático** → ligar.
3. Crie uma tarefa no dispositivo A.
4. **Sincronizar agora** ou reabra o app no dispositivo B (mesmo `device_id` só no mesmo aparelho; para multi-device futuro: auth por email).

> **Nota MVP:** sync usa `device_id` local (UUID). Multi-dispositivo com mesma conta exige auth Supabase (fase futura).

---

## 2. LLM subtarefas (OpenAI) — ✅ configurado

Edge Function `suggest-subtasks` em produção; secrets definidos no Supabase.

### 2.1 Validar no app

1. Usuário **Pro** (sandbox RevenueCat ou dev).
2. **+ Começar algo** → digite tarefa → **Começar 🚀**.
3. Subtarefas vêm do proxy (`AI_PROXY_URL`); fallback heurístico se a API falhar.

### 2.2 Dev local (opcional)

Em `.env.local`, `OPENAI_API_KEY` permite chamar OpenAI direto em debug (sem proxy).

### 2.3 Release

Use só `AI_PROXY_URL` em `./scripts/build_release.sh` — **não** inclua `OPENAI_API_KEY` no build de loja.

### 2.4 Privacidade

Política já menciona envio de títulos à OpenAI para usuários Pro ao criar tarefa.

---

## 3. Android — release na Play Store

### Passo a passo

1. **Keystore**
  ```bash
   keytool -genkey -v -keystore ~/todoin-release.keystore \
     -alias todoin -keyalg RSA -keysize 2048 -validity 10000
  ```
2. Copie `android/key.properties.example` → `android/key.properties` e preencha.
3. Build: `./scripts/build_release.sh` (com `.env.local` carregado).
4. Play Console → criar app `com.cubitapp.todoinapp`.
5. Produtos: `todoin_pro_monthly`, `todoin_pro_yearly`, `todoin_pro_lifetime`.
6. RevenueCat: vincular produtos + entitlement `pro`.
7. Data safety + foreground service justification.
8. Upload do `.aab` da pasta `build/app/outputs/bundle/release/`.

---

## 4. iOS — App Store

### Passo a passo

1. **Apple Developer** → App ID `com.cubitapp.todoinapp`.
2. **App Groups** → `group.com.cubitapp.todoinapp` (Runner + extensões).
3. **Widget iOS** (validar no simulador):
  - Abra `ios/Runner.xcworkspace`.
  - Target `TodoinExtensionsExtension` já configurado — siga `[ios/TodoinExtensions/README.md](../ios/TodoinExtensions/README.md)`.
4. **Certificados** → Distribution + Provisioning Profile.
5. App Store Connect → app + produtos IAP (mesmos IDs).
6. RevenueCat → Apple Shared Secret / StoreKit 2.
7. Build: `flutter build ipa --release` + dart-defines.
8. Upload via Transporter ou Xcode Organizer.
9. TestFlight → validar Live Activity em **dispositivo físico**.

---

## 5. RevenueCat — checklist

- Projeto `todoin` criado
- Entitlement `pro` configurado
- Offering `default` com monthly / annual / lifetime
- Product IDs iguais ao código (`product_catalog.dart`)
- `REVENUECAT_APPLE_API_KEY` e `REVENUECAT_GOOGLE_API_KEY` no release build
- Sandbox: compra + restore + expiração revoga Pro local

---

## 6. Observabilidade — checklist

- PostHog: eventos `app_opened`, `task_`*, `paywall_*` em Live events
- Sentry: erro de teste aparece no dashboard
- Política de privacidade menciona PostHog, Sentry, OpenAI (Pro), Supabase (Pro)

---

## 7. URLs legais — ✅ publicadas (Notion)

- `lib/core/constants/legal_urls.dart` aponta para páginas Notion.
- Pendente: configurar caixa de email `suporte@todoin.app` (domínio).

---

## 8. Fases futuras (não implementadas)


| Item                                | Fase | Esforço              |
| ----------------------------------- | ---- | -------------------- |
| Auth email (sync multi-device)      | 3+   | Médio                |
| Widget iOS CI automatizado          | 3+   | Baixo                    |
| Apple Watch                         | 4+   | Alto                 |
| Wear OS                             | 4+   | Alto                 |
| Calendário read-only                | 3    | Médio                |
| Body doubling / som customizado Pro | 2    | Médio                |
| Customer Center RevenueCat          | 2    | Baixo                |


---

## 9. Ordem recomendada de execução

```
1. ~~Supabase (sync) + OpenAI (LLM)~~ — concluído
2. Android keystore + build release
3. RevenueCat + produtos loja (sandbox)
4. Widget iOS no Xcode
5. URLs legais publicadas
6. TestFlight + Play Internal Testing
7. Submissão produção
8. Monitorar PostHog + Sentry pós-lançamento
```

---

## 10. Comando release completo

```bash
# .env.local com todas as chaves
./scripts/build_release.sh
```

Variáveis suportadas: ver `[.env.local.example](../.env.local.example)` e `[CONFIGURACAO_LANCAMENTO.md](CONFIGURACAO_LANCAMENTO.md)`.