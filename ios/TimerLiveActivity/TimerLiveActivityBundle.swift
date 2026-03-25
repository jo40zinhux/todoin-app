import WidgetKit
import SwiftUI

// ═══════════════════════════════════════════════════
// MARK: – Widget Bundle Entry Point
//
// Este é o @main do target TimerLiveActivity.
// Registra apenas o widget de Live Activity (TodoinTimerLiveActivity).
// Os demais arquivos gerados pelo Xcode (TimerLiveActivity.swift,
// TimerLiveActivityLiveActivity.swift, etc.) foram esvaziados pois
// o toDoin usa apenas a Live Activity customizada.
// ═══════════════════════════════════════════════════

@main
struct TodoinTimerLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        if #available(iOS 16.1, *) {
            TodoinTimerLiveActivity()
        }
    }
}

