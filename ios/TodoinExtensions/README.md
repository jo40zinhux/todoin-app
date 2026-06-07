# toDoin — iOS Extensions (unificado)

Target Xcode: **`TodoinExtensionsExtension`**  
Pasta: `ios/TodoinExtensions/`

Registra num único `WidgetBundle`:
- **Home Widget** (`TodoinHomeWidget`, kind `TodoinWidgetExtension`) — Pro
- **Live Activity** (`TodoinTimerLiveActivity`) — timer ativo

## Configuração

1. `open ios/Runner.xcworkspace`
2. Target **TodoinExtensionsExtension** → pasta `TodoinExtensions/`
3. **Signing & Capabilities** → App Groups → `group.com.cubitapp.todoinapp`
4. Bundle ID: `com.cubitapp.todoinapp.TodoinExtensions`
5. Build & run

## Flutter

| Serviço | Plugin | iOSName / kind |
|---------|--------|----------------|
| `WidgetDataService` | `home_widget` | `TodoinWidgetExtension` |
| `LiveActivityService` | `live_activities` | App Group |

## Teste

```bash
./scripts/run_dev.sh
```
