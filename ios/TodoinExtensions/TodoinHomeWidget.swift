//
//  TodoinHomeWidget.swift
//  TodoinExtensions
//

import WidgetKit
import SwiftUI

private let appGroupId = "group.com.cubitapp.todoinapp"

struct TodoinEntry: TimelineEntry {
    let date: Date
    let taskTitle: String
    let streak: Int
    let xp: Int
    let isPro: Bool
}

struct TodoinProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoinEntry {
        TodoinEntry(
            date: Date(),
            taskTitle: "Sua tarefa agora",
            streak: 0,
            xp: 0,
            isPro: false
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodoinEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoinEntry>) -> Void) {
        let entry = readEntry()
        let timeline = Timeline(
            entries: [entry],
            policy: .after(Date().addingTimeInterval(900))
        )
        completion(timeline)
    }

    private func readEntry() -> TodoinEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        return TodoinEntry(
            date: Date(),
            taskTitle: defaults?.string(forKey: "widget_current_task") ?? "Abra o toDoin",
            streak: defaults?.integer(forKey: "widget_streak") ?? 0,
            xp: defaults?.integer(forKey: "widget_xp") ?? 0,
            isPro: defaults?.bool(forKey: "widget_is_pro") ?? false
        )
    }
}

struct TodoinHomeWidgetView: View {
    var entry: TodoinEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("toDoin")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(Color(red: 0.49, green: 0.36, blue: 0.99))

            Text(entry.taskTitle)
                .font(.headline)
                .lineLimit(2)

            if entry.isPro {
                Text("🔥 \(entry.streak) · ⭐ \(entry.xp) XP")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("toDoin Pro")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

/// kind deve coincidir com WidgetDataService.iOSName no Flutter.
struct TodoinHomeWidget: Widget {
    let kind: String = "TodoinWidgetExtension"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoinProvider()) { entry in
            if #available(iOS 17.0, *) {
                TodoinHomeWidgetView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                TodoinHomeWidgetView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("toDoin")
        .description("Sua tarefa atual e progresso.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
