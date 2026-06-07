# toDoin — Guia de Configuração para Lançamento

Este documento lista **todos os passos** para publicar o toDoin na App Store e Google Play, incluindo onde obter chaves, o que configurar em cada painel e como conectar ao código do projeto.

---

## Índice

1. [Pré-requisitos gerais](#1-pré-requisitos-gerais)
2. [Contas e identificadores do app](#2-contas-e-identificadores-do-app)
3. [RevenueCat + Assinaturas (iOS e Android)](#3-revenuecat--assinaturas-ios-e-android)
4. [Apple App Store Connect (iOS)](#4-apple-app-store-connect-ios)
5. [Google Play Console (Android)](#5-google-play-console-android)
6. [Configuração nativa iOS (Xcode)](#6-configuração-nativa-ios-xcode)
7. [Configuração nativa Android](#7-configuração-nativa-android)
8. [Observabilidade (Sentry + Analytics)](#8-observabilidade-sentry--analytics)
9. [Documentos legais e ASO](#9-documentos-legais-e-aso)
10. [Build de produção com chaves](#10-build-de-produção-com-chaves)
11. [Checklist final antes de submeter](#11-checklist-final-antes-de-submeter)

---

## 1. Pré-requisitos gerais

| Item | Onde criar | Custo aproximado |
|------|------------|------------------|
| Apple Developer Program | [developer.apple.com](https://developer.apple.com) | US$ 99/ano |
| Google Play Console | [play.google.com/console](https://play.google.com/console) | US$ 25 (único) |
| RevenueCat | [app.revenuecat.com](https://app.revenuecat.com) | Grátis até US$ 2.5k MTR |
| Sentry (crashes) | [sentry.io](https://sentry.io) | Plano gratuito disponível |
| Domínio + páginas legais | Seu registrador / Notion / GitHub Pages | Variável |

**Identificadores já usados no projeto:**

| Plataforma | Valor |
|------------|-------|
| Bundle ID (iOS) | `com.cubitapp.todoinapp` |
| Application ID (Android) | `com.cubitapp.todoinapp` |
| App Group (iOS) | `group.com.cubitapp.todoinapp` |
| Entitlement RevenueCat | `pro` |

---

## 2. Contas e identificadores do app

### 2.1 Apple

1. Acesse [App Store Connect](https://appstoreconnect.apple.com).
2. **Meus Apps → + → Novo App**.
3. Preencha:
   - **Nome:** toDoin
   - **Idioma principal:** Português (Brasil)
   - **Bundle ID:** `com.cubitapp.todoinapp` (deve existir em Certificates, Identifiers & Profiles)
   - **SKU:** `todoin-ios` (qualquer string única interna)
4. Em [Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources):
   - Confirme o App ID `com.cubitapp.todoinapp`
   - Habilite: **Push Notifications**, **App Groups**, **In-App Purchase**
   - App Group: `group.com.cubitapp.todoinapp`

### 2.2 Google

1. Acesse [Google Play Console](https://play.google.com/console).
2. **Criar app → toDoin**.
3. O `applicationId` já está em `android/app/build.gradle`:
   ```gradle
   applicationId = "com.cubitapp.todoinapp"
   ```
4. **Não altere** o applicationId após publicar (quebra atualizações).

---

## 3. RevenueCat + Assinaturas (iOS e Android)

O app usa `purchases_flutter`. Sem chaves, opera em **modo dev** (Pro local). Para produção, configure o RevenueCat.

### 3.1 Criar projeto no RevenueCat

1. Acesse [app.revenuecat.com](https://app.revenuecat.com) → **New Project** → `toDoin`.
2. Adicione apps:
   - **iOS:** Bundle ID `com.cubitapp.todoinapp`
   - **Android:** Package `com.cubitapp.todoinapp`

### 3.2 Onde pegar as API Keys

No RevenueCat → **Project Settings → API keys**:

| Chave | Formato | Uso no app |
|-------|---------|------------|
| Apple API Key | `appl_xxxxxxxx` | `--dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx` |
| Google API Key | `goog_xxxxxxxx` | `--dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxx` |

Arquivo no código: `lib/core/config/billing_config.dart`

### 3.3 Criar produtos nas lojas

**IDs de produto (devem coincidir com `ProductCatalog` no código):**

| ID do produto | Tipo | Preço sugerido (BR) |
|---------------|------|---------------------|
| `todoin_pro_monthly` | Assinatura mensal | R$ 12,90 |
| `todoin_pro_yearly` | Assinatura anual | R$ 59,90 |
| `todoin_pro_lifetime` | Compra única (iOS) / in-app (Android) | R$ 89,90 |

#### App Store Connect → Assinaturas

1. **Meus Apps → toDoin → Assinaturas**.
2. Crie um **Grupo de assinaturas**: `toDoin Pro`.
3. Adicione assinaturas:
   - `todoin_pro_monthly` — 1 mês
   - `todoin_pro_yearly` — 1 ano
4. Para vitalício: **Compras no app** (Non-Consumable) → `todoin_pro_lifetime`.
5. Preencha preços, localização PT-BR e screenshot de revisão (pode ser mockup do paywall).

#### Google Play Console → Monetização

1. **Monetizar → Produtos → Assinaturas**:
   - `todoin_pro_monthly`
   - `todoin_pro_yearly`
2. **Monetizar → Produtos → Produtos no app** (gerenciados):
   - `todoin_pro_lifetime`
3. Ative **Conta do comerciante** e **acordos fiscais** antes de publicar.

### 3.4 Configurar Entitlements no RevenueCat

1. **Entitlements → + New** → Identifier: `pro` (igual a `BillingConfig.entitlementId`).
2. **Products → + New** → vincule os 3 product IDs de cada loja.
3. Associe todos os produtos ao entitlement `pro`.
4. **Offerings → default** → adicione packages:
   - Monthly → `todoin_pro_monthly`
   - Annual → `todoin_pro_yearly`
   - Lifetime → `todoin_pro_lifetime`

### 3.5 Credenciais de loja no RevenueCat

- **iOS:** App Store Connect API Key (`.p8`) em RevenueCat → Apple App Store.
  - Criar em App Store Connect → **Usuários e Acesso → Integrações → App Store Connect API**.
- **Android:** Service Account JSON em RevenueCat → Google Play.
  - Play Console → **Configurações → Acesso à API → Criar projeto vinculado**.

### 3.6 Testar compras

| Ambiente | iOS | Android |
|----------|-----|---------|
| Sandbox | Conta Sandbox em App Store Connect → Usuários e Acesso | Conta de teste licenciada na Play Console |
| RevenueCat | Customer history no dashboard | Idem |

---

## 4. Apple App Store Connect (iOS)

### 4.1 Metadados obrigatórios

- **Nome:** toDoin
- **Subtítulo:** Foco gentil para o dia a dia
- **Descrição:** foco em TDAH, passos pequenos, timer 2 min, sem culpa
- **Palavras-chave:** tdah, foco, tarefas, produtividade, timer, hábitos
- **Categoria:** Produtividade (primária), Saúde e fitness (secundária)
- **Classificação etária:** 4+
- **URL de suporte:** `https://todoin.app/suporte` (ou email `suporte@todoin.app`)
- **URL política de privacidade:** `https://todoin.app/privacidade`

### 4.2 Screenshots (obrigatório)

Tamanhos mínimos (iPhone 6.7" e 6.5"):
1. Home com tarefa ativa
2. Timer de foco
3. Paywall / Pro
4. Progresso / streak
5. Onboarding

### 4.3 App Review — informações para revisão

- **Conta demo:** não necessária (app funciona offline)
- **Notas:** app local-first, assinatura opcional, notificações para timer e lembretes gentis
- Se usar compras: inclua conta sandbox para o revisor testar Pro

### 4.4 Capabilities no Xcode (já parcialmente configurado)

| Capability | Status no projeto | Ação |
|------------|-------------------|------|
| App Groups | ✅ `group.com.cubitapp.todoinapp` | Verificar em Runner + TodoinExtensionsExtension |
| Push Notifications | Parcial (notificações locais) | Não precisa de certificado APNs para local |
| In-App Purchase | Necessário para Pro | Habilitar no App ID |
| Live Activities | ✅ target `TodoinExtensionsExtension` | Manter |

### 4.5 Assinatura do build (Release)

1. Xcode → Runner → **Signing & Capabilities**.
2. Selecione seu **Team** Apple Developer.
3. **Automatically manage signing** (recomendado).
4. Para CI: use certificado de distribuição + provisioning profile.

```bash
flutter build ipa --release \
  --dart-define=REVENUECAT_APPLE_API_KEY=appl_xxx \
  --dart-define=SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
```

Upload via Xcode Organizer ou `xcrun altool`.

---

## 5. Google Play Console (Android)

### 5.1 Configuração inicial

1. **Política de privacidade:** URL obrigatória (`https://todoin.app/privacidade`).
2. **Formulário de segurança de dados:** declare SharedPreferences local, sem coleta de dados pessoais identificáveis (ajuste se adicionar analytics).
3. **Público-alvo:** 13+ ou conforme conteúdo.
4. **Categoria:** Produtividade.

### 5.2 Assinatura do app (obrigatório para release)

1. Gere keystore:
   ```bash
   keytool -genkey -v -keystore ~/todoin-release.keystore \
     -alias todoin -keyalg RSA -keysize 2048 -validity 10000
   ```
2. Crie `android/key.properties` (não commitar):
   ```properties
   storePassword=SUA_SENHA
   keyPassword=SUA_SENHA
   keyAlias=todoin
   storeFile=/caminho/para/todoin-release.keystore
   ```
3. Atualize `android/app/build.gradle` com `signingConfigs.release` (ver seção 7).

### 5.3 Permissões declaradas

O app já declara em `AndroidManifest.xml`:

| Permissão | Motivo |
|-----------|--------|
| `POST_NOTIFICATIONS` | Timer e lembretes gentis |
| `FOREGROUND_SERVICE` | Timer em background |
| `RECEIVE_BOOT_COMPLETED` | Reagendar lembretes após reboot |

Na Play Console → **Política de permissões**, justifique o foreground service como "timer de foco ativo".

### 5.4 Build de release

```bash
flutter build appbundle --release \
  --dart-define=REVENUECAT_GOOGLE_API_KEY=goog_xxx \
  --dart-define=SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
```

Upload do `.aab` em **Produção → Criar nova versão**.

---

## 6. Configuração nativa iOS (Xcode)

### 6.1 Abrir projeto

```bash
open ios/Runner.xcworkspace
```

### 6.2 App Group (Widget + Live Activity)

Já configurado em `ios/Runner/RunnerRelease.entitlements`:
```xml
<string>group.com.cubitapp.todoinapp</string>
```

Repita em:
- Target **Runner** (Debug + Release)
- Target **TodoinExtensionsExtension** (código em `ios/TodoinExtensions/`)

### 6.3 Extensões iOS (Widget + Live Activity)

Target unificado. Valide no Xcode:

1. Abra `ios/Runner.xcworkspace`.
2. Confirme target **TodoinExtensionsExtension** → pasta `ios/TodoinExtensions/`.
3. **Signing & Capabilities** → App Groups → `group.com.cubitapp.todoinapp`.
4. Bundle ID: `com.cubitapp.todoinapp.TodoinExtensions`.
5. Build & adicione o widget **toDoin** na home (usuário Pro).

Flutter: `WidgetDataService` usa `iOSName: 'TodoinWidgetExtension'`. Detalhes: `ios/TodoinExtensions/README.md`.

### 6.4 Live Activity (consolidado)

Live Activity e Home Widget compartilham o target **TodoinExtensionsExtension**:

- Bundle ID: `com.cubitapp.todoinapp.TodoinExtensions`
- Código: `ios/TodoinExtensions/TodoinTimerLiveActivity.swift`
- `NSSupportsLiveActivities` em `ios/TodoinExtensions/Info.plist`

O kind do widget (`TodoinWidgetExtension`) é apenas o identificador WidgetKit usado pelo Flutter — não é um target separado.

### 6.5 Notificações locais

Não requer configuração extra no portal Apple. O app solicita permissão em runtime.

---

## 7. Configuração nativa Android

### 7.1 Assinatura release

Adicione ao `android/app/build.gradle` (se ainda não fez):

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 7.2 Widget (Pro)

Arquivos em `android/app/src/main/`:

| Arquivo | Função |
|---------|--------|
| `kotlin/.../TodoinWidget.kt` | Provider do widget |
| `res/layout/todoin_widget.xml` | Layout |
| `res/xml/todoin_widget_info.xml` | Configuração do widget |
| `AndroidManifest.xml` | Registro do receiver |

Após instalar o app: long-press na home → Widgets → toDoin.

### 7.3 home_widget

O Dart usa `WidgetDataService` com App Group / SharedPreferences do plugin.
Confirme que `group.com.cubitapp.todoinapp` está alinhado (Android usa SharedPreferences interno do plugin).

---

## 8. Observabilidade (Sentry + Analytics)

### 8.1 Sentry (crash reporting)

1. Crie projeto em [sentry.io](https://sentry.io) → Flutter.
2. Copie o **DSN** (formato `https://xxx@xxx.ingest.sentry.io/xxx`).
3. Passe na build:
   ```bash
   --dart-define=SENTRY_DSN=https://...
   ```
4. Arquivo: `lib/core/config/observability_config.dart`

**Opcional iOS:** upload de dSYM no build para stack traces legíveis.

### 8.2 PostHog (analytics — integração completa)

#### Criar projeto

1. Acesse [posthog.com](https://posthog.com) → **New project** → `toDoin`.
2. Escolha região:
   - EU: `https://eu.i.posthog.com`
   - US: `https://us.i.posthog.com` (padrão no código)

#### Onde pegar a API Key

PostHog → **Project Settings → Project API Key**

| Valor | Formato | dart-define |
|-------|---------|-------------|
| Project API Key | `phc_xxxxxxxx` | `POSTHOG_API_KEY` |
| Host | `https://us.i.posthog.com` | `POSTHOG_HOST` |
| Debug SDK | `true` / `false` | `POSTHOG_DEBUG` |

Arquivos no código:
- `lib/core/config/observability_config.dart`
- `lib/core/services/posthog_service.dart`
- `lib/core/services/analytics_service.dart`

#### Configuração nativa (já feita no projeto)

O SDK usa **inicialização manual** no Dart (não coloque o token no manifest/plist):

- **Android:** `AndroidManifest.xml` → `com.posthog.posthog.AUTO_INIT = false`
- **iOS:** `Info.plist` → `com.posthog.posthog.AUTO_INIT = false`

> **Nota:** o projeto usa Flutter 3.22 e `posthog_flutter: 4.11.0` (versões 5.17+ exigem Flutter 3.27).

#### Testar localmente

```bash
flutter run \
  --dart-define=POSTHOG_API_KEY=phc_SUA_CHAVE \
  --dart-define=POSTHOG_HOST=https://us.i.posthog.com \
  --dart-define=POSTHOG_DEBUG=true
```

#### Validar no dashboard PostHog

1. Abra o app (simulador ou dispositivo).
2. No PostHog → **Activity → Live events**.
3. Confirme os eventos:
   - `app_opened` — no startup
   - `$screen` — `home` ou `onboarding`
   - `task_created`, `task_completed`, `timer_started`
   - `paywall_shown`, `purchase_started`, `purchase_completed`
   - `onboarding_completed`, `backup_exported`, `backup_imported`

4. Em **Persons**, verifique propriedades após compra Pro:
   - `is_pro: true`
   - `plan_type: monthly | yearly | lifetime`

#### Super properties registradas automaticamente

- `app_name`: todoin
- `platform`: ios / android
- `build_mode`: debug / release

#### Privacidade (importante para as lojas)

Atualize a política de privacidade mencionando:
- PostHog coleta eventos de uso anonimizados
- `personProfiles: identifiedOnly` — perfis só após `identify` (compra Pro)
- Sem dados de tarefas pessoais enviados no PostHog (títulos **não** são tracked)
- OpenAI (Pro): títulos enviados só ao criar subtarefas inteligentes
- Supabase (Pro): backup JSON sincronizado por `device_id`

### 8.3 Cloud Sync (Supabase — Pro)

1. Crie projeto em [supabase.com](https://supabase.com).
2. Execute o SQL em [`docs/supabase_schema.sql`](supabase_schema.sql).
3. Copie **Project URL** e **anon key** (Settings → API).

| Valor | dart-define |
|-------|-------------|
| Project URL | `SUPABASE_URL` |
| anon public key | `SUPABASE_ANON_KEY` |

No app: **Configurações → Sync automático** (requer Pro).

### 8.4 LLM subtarefas (OpenAI — Pro)

1. [platform.openai.com](https://platform.openai.com) → API Keys.
2. Configure:

| Valor | dart-define |
|-------|-------------|
| API Key | `OPENAI_API_KEY` |
| Modelo | `OPENAI_MODEL` (default `gpt-4o-mini`) |

Fallback automático para heurísticas locais se a API falhar.

---

## 9. Documentos legais e ASO

### 9.1 URLs legais (app + lojas)

Arquivo: `lib/core/constants/legal_urls.dart`

| Documento | URL no app | Ação nas lojas |
|-----------|------------|----------------|
| Privacidade | Notion (ver `legal_urls.dart`) | ✅ Usar a mesma URL no App Store Connect e Play Console |
| Termos | Notion (ver `legal_urls.dart`) | ✅ Usar a mesma URL onde solicitado |
| Suporte | `suporte@todoin.app` | ⚠️ Criar caixa de email antes da submissão |

> Conteúdo fonte em `docs/legal/POLITICA_DE_PRIVACIDADE.md` e `docs/legal/TERMOS_DE_USO.md`.

**Conteúdo mínimo da privacidade:**
- Dados armazenados localmente (tarefas, XP, configurações)
- RevenueCat processa pagamentos (link política RevenueCat)
- Sentry recebe crashes anônimos (se ativado)
- Sem venda de dados a terceiros

### 9.2 ASO (App Store Optimization)

**Título:** toDoin — Foco Gentil  
**Subtítulo iOS:** Tarefas pequenas, menos procrastinação  
**Descrição curta Android:** App de foco para TDAH. Comece pequeno, sem culpa.

---

## 10. Build de produção com chaves

### 10.0 Desenvolvimento local (recomendado)

Com `.env.local` preenchido:

```bash
./scripts/run_dev.sh
```

Carrega automaticamente PostHog, Sentry, RevenueCat, Supabase e OpenAI via dart-define.

### 10.1 Arquivo de exemplo (não commitar)

Crie `scripts/build_release.sh`:

```bash
#!/bin/bash
set -e

# Carregue de .env.local (não versionado)
source .env.local 2>/dev/null || true

flutter build appbundle --release \
  --dart-define=REVENUECAT_GOOGLE_API_KEY="${REVENUECAT_GOOGLE_API_KEY}" \
  --dart-define=SENTRY_DSN="${SENTRY_DSN}" \
  --dart-define=POSTHOG_API_KEY="${POSTHOG_API_KEY}"

flutter build ipa --release \
  --dart-define=REVENUECAT_APPLE_API_KEY="${REVENUECAT_APPLE_API_KEY}" \
  --dart-define=SENTRY_DSN="${SENTRY_DSN}" \
  --dart-define=POSTHOG_API_KEY="${POSTHOG_API_KEY}"
```

### 10.2 `.env.local` (exemplo — adicionar ao `.gitignore`)

```bash
REVENUECAT_APPLE_API_KEY=appl_xxxxxxxx
REVENUECAT_GOOGLE_API_KEY=goog_xxxxxxxx
SENTRY_DSN=https://xxx@xxx.ingest.sentry.io/xxx
POSTHOG_API_KEY=phc_xxxxxxxx
POSTHOG_HOST=https://us.i.posthog.com
```

### 10.3 Todas as dart-defines suportadas

| Variável | Obrigatória | Descrição |
|----------|-------------|-----------|
| `REVENUECAT_APPLE_API_KEY` | Para IAP iOS | Public API Key RevenueCat |
| `REVENUECAT_GOOGLE_API_KEY` | Para IAP Android | Public API Key RevenueCat |
| `SENTRY_DSN` | Recomendada | Crash reporting |
| `POSTHOG_API_KEY` | Recomendada | Analytics PostHog |
| `POSTHOG_HOST` | Opcional | Host PostHog (default US) |
| `POSTHOG_DEBUG` | Opcional | Logs do SDK PostHog |
| `SUPABASE_URL` | Pro sync | URL do projeto Supabase |
| `SUPABASE_ANON_KEY` | Pro sync | Chave anon Supabase |
| `AI_PROXY_URL` | Pro AI (produção) | Edge Function `suggest-subtasks` |
| `OPENAI_API_KEY` | Pro AI (servidor) | Secret no Supabase, não no app release |
| `OPENAI_MODEL` | Opcional | Modelo OpenAI (default mini) |

> Passo a passo completo das pendências: [`docs/IMPLEMENTACOES_PENDENTES.md`](IMPLEMENTACOES_PENDENTES.md)

---

## 11. Checklist final antes de submeter

### Código e build
- [x] URLs legais publicadas (Notion) em `legal_urls.dart`
- [ ] `./scripts/deploy_supabase.sh` (drop `app_sync` legado + Edge Function com JWT)
- [ ] API keys RevenueCat nas builds de release
- [ ] Keystore Android configurado (não debug)
- [ ] Certificado iOS de distribuição
- [x] CI GitHub Actions (`flutter analyze` + `flutter test`)
- [x] `flutter test` passando localmente (91 testes)
- [ ] Testado compra sandbox (iOS + Android)
- [ ] Testado restore purchases
- [ ] Widget iOS e Android adicionados manualmente na home (Pro)
- [ ] Live Activity funciona em dispositivo físico iOS 16.1+

### App Store Connect
- [ ] Screenshots 6.7" e 6.5"
- [ ] Descrição e palavras-chave
- [ ] Política de privacidade URL
- [ ] Assinaturas aprovadas e vinculadas ao RevenueCat
- [ ] Notas para revisor

### Google Play
- [ ] AAB assinado uploadado
- [ ] Data safety form preenchido
- [ ] Política de privacidade URL
- [ ] Assinaturas ativas
- [ ] Conta comerciante verificada

### Pós-lançamento
- [ ] Monitorar Sentry (crashes)
- [ ] Monitorar RevenueCat (conversão, churn)
- [ ] Responder reviews nas primeiras 2 semanas
- [ ] Ajustar preços por país se necessário

---

## Referências rápidas no código

| Funcionalidade | Arquivo principal |
|----------------|-------------------|
| RevenueCat | `lib/core/services/billing_service.dart` |
| Config billing | `lib/core/config/billing_config.dart` |
| Produtos / preços UI | `lib/core/constants/product_catalog.dart` |
| Limites free | `lib/core/constants/free_tier_limits.dart` |
| Widget data | `lib/core/services/widget_data_service.dart` |
| Lembretes | `lib/features/reminders/` |
| URLs legais | `lib/core/constants/legal_urls.dart` |
| Observabilidade | `lib/core/config/observability_config.dart` |
| PostHog SDK | `lib/core/services/posthog_service.dart` |
| Analytics | `lib/core/services/analytics_service.dart` |
| Export backup | `lib/features/backup/` |

---

## Suporte

Dúvidas sobre este guia: abra uma issue no repositório ou contate `suporte@todoin.app`.

*Última atualização: junho 2026 — alinhado ao bundle `com.cubitapp.todoinapp`.*
