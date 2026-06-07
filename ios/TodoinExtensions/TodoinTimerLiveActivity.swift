import ActivityKit
import WidgetKit
import SwiftUI

// ═══════════════════════════════════════════════════
// MARK: – Live Activity / Dynamic Island Widget
// ═══════════════════════════════════════════════════
// O @main WidgetBundle está em TodoinExtensionsBundle.swift.

@available(iOS 16.1, *)
struct TodoinTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TodoinTimerAttributes.self) { context in
            // ── Lock Screen / Banner (todos os iPhones com iOS 16.1+) ──
            LockScreenView(context: context)
        } dynamicIsland: { context in
            // ── Dynamic Island (iPhone 14 Pro+ e modelos superiores) ──
            DynamicIsland {
                // Expanded (pressionando a ilha)
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                // Compact – lado esquerdo da ilha
                Image(systemName: context.state.isCompleted ? "checkmark.circle.fill" : "brain.head.profile")
                    .foregroundStyle(Color("LaunchBackground", bundle: nil) != .clear ? .white : .purple)
                    .font(.system(size: 14, weight: .semibold))
            } compactTrailing: {
                // Compact – lado direito da ilha (contagem regressiva)
                if context.state.isCompleted {
                    Text("✓")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.green)
                } else {
                    Text(timerInterval: Date.now...context.attributes.timerEndDate, countsDown: true)
                        .monospacedDigit()
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 44)
                }
            } minimal: {
                // Minimal – quando outra app também tem ilha ativa
                Image(systemName: context.state.isCompleted ? "checkmark.circle.fill" : "timer")
                    .foregroundStyle(context.state.isCompleted ? .green : .white)
                    .font(.system(size: 12, weight: .bold))
            }
            .keylineTint(.purple)
            .contentMargins(.horizontal, 14, for: .expanded)
        }
    }
}

// ═══════════════════════════════════════════════════
// MARK: – Lock Screen View
// ═══════════════════════════════════════════════════

@available(iOS 16.1, *)
struct LockScreenView: View {
    let context: ActivityViewContext<TodoinTimerAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // Ícone
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.49, green: 0.36, blue: 0.99),
                                     Color(red: 0.31, green: 0.20, blue: 0.86)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                Image(systemName: context.state.isCompleted
                      ? "checkmark.circle.fill" : "brain.head.profile")
                    .foregroundStyle(.white)
                    .font(.system(size: 22, weight: .bold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(context.state.isCompleted ? "Foco concluído! 🎉" : context.attributes.taskTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)

                if context.state.isCompleted {
                    Text("Você focou por 2 minutos. Parabéns!")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                } else {
                    Text("toDoin · Modo foco")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Contagem regressiva / check
            if context.state.isCompleted {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
                    .font(.system(size: 28, weight: .bold))
            } else {
                Text(timerInterval: Date.now...context.attributes.timerEndDate, countsDown: true)
                    .monospacedDigit()
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.49, green: 0.36, blue: 0.99))
                    .frame(minWidth: 52, alignment: .trailing)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.regularMaterial)
    }
}

// ═══════════════════════════════════════════════════
// MARK: – Dynamic Island Expanded Views
// ═══════════════════════════════════════════════════

@available(iOS 16.1, *)
struct ExpandedLeadingView: View {
    let context: ActivityViewContext<TodoinTimerAttributes>

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: context.state.isCompleted
                  ? "checkmark.circle.fill" : "brain.head.profile")
                .foregroundStyle(context.state.isCompleted ? .green : .white)
                .font(.system(size: 20, weight: .semibold))

            Text(context.state.isCompleted ? "Concluído" : "Foco ativo")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
        }
    }
}

@available(iOS 16.1, *)
struct ExpandedTrailingView: View {
    let context: ActivityViewContext<TodoinTimerAttributes>

    var body: some View {
        if context.state.isCompleted {
            Text("🎉")
                .font(.system(size: 24))
        } else {
            Text(timerInterval: Date.now...context.attributes.timerEndDate, countsDown: true)
                .monospacedDigit()
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(minWidth: 52, alignment: .trailing)
        }
    }
}

@available(iOS 16.1, *)
struct ExpandedBottomView: View {
    let context: ActivityViewContext<TodoinTimerAttributes>

    var body: some View {
        if !context.state.isCompleted {
            VStack(spacing: 6) {
                // Barra de progresso (estimativa visual)
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.2))
                            .frame(height: 4)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white)
                            .frame(
                                width: geo.size.width * CGFloat(context.state.remainingSeconds) / 120.0,
                                height: 4
                            )
                    }
                }
                .frame(height: 4)
                .padding(.horizontal, 4)

                Text("toDoin · Mantenha o foco!")
                    .font(.system(size: 11))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.bottom, 8)
        } else {
            Text("Cada passo conta. Continue assim! 🚀")
                .font(.system(size: 12))
                .foregroundStyle(.white.opacity(0.8))
                .padding(.bottom, 8)
        }
    }
}

// ═══════════════════════════════════════════════════
// MARK: – Previews
// ═══════════════════════════════════════════════════

#if canImport(SwiftUI) && DEBUG
@available(iOS 16.2, *)
struct TodoinTimerLiveActivity_Previews: PreviewProvider {
    static let attributes = TodoinTimerAttributes(
        timerEndMillis: Date().addingTimeInterval(90).timeIntervalSince1970 * 1000,
        taskTitle: "Foco ativo"
    )
    static let contentState = TodoinTimerAttributes.ContentState(
        remainingSeconds: 90,
        isCompleted: false
    )
    static let completedState = TodoinTimerAttributes.ContentState(
        remainingSeconds: 0,
        isCompleted: true
    )

    static var previews: some View {
        Group {
            attributes
                .previewContext(contentState, viewKind: .content)
                .previewDisplayName("Lock Screen – Ativo")

            attributes
                .previewContext(completedState, viewKind: .content)
                .previewDisplayName("Lock Screen – Concluído")

            attributes
                .previewContext(contentState, viewKind: .dynamicIsland(.compact))
                .previewDisplayName("DI – Compact")

            attributes
                .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
                .previewDisplayName("DI – Expanded")

            attributes
                .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
                .previewDisplayName("DI – Minimal")
        }
    }
}
#endif
