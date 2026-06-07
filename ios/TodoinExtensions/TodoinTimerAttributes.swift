import ActivityKit
import WidgetKit
import SwiftUI

// ═══════════════════════════════════════════════════
// MARK: – Activity Attributes (contrato com Flutter)
// ═══════════════════════════════════════════════════

/// Define os dados da Live Activity do timer toDoin.
/// Os campos de `ContentState` são enviados pelo Flutter via live_activities plugin.
public struct TodoinTimerAttributes: ActivityAttributes {
    public typealias TodoinTimerStatus = ContentState

    /// Estado dinâmico – atualizado via `live_activities` a cada tick do timer.
    public struct ContentState: Codable, Hashable {
        /// Segundos restantes no timer.
        var remainingSeconds: Int
        /// Se o timer foi concluído.
        var isCompleted: Bool
    }

    /// Dados estáticos – definidos ao iniciar a Activity.
    /// Timestamp de quando o timer termina (Double, millisecondsSinceEpoch, para evitar erros de decoding de Date).
    var timerEndMillis: Double
    var taskTitle: String
    
    /// Converte o timerEndMillis (Double) de volta para um objeto Date do Swift
    var timerEndDate: Date {
        Date(timeIntervalSince1970: timerEndMillis / 1000)
    }
}

// ═══════════════════════════════════════════════════
// MARK: – Helpers
// ═══════════════════════════════════════════════════

extension TodoinTimerAttributes.ContentState {
    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
