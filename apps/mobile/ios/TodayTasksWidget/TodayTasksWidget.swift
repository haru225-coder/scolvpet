import WidgetKit
import SwiftUI

/// WidgetKit scaffold for 今日待办 (T-P1-05).
/// Add this target in Xcode with App Group `group.cn.scolvpet.dev` mirroring
/// Flutter SharedPreferences / App Group keys from `TodayWidgetKeys`.
struct TodayTasksEntry: TimelineEntry {
    let date: Date
    let headline: String
    let countLabel: String
    let body: String
}

struct TodayTasksProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayTasksEntry {
        TodayTasksEntry(
            date: Date(),
            headline: "今日待办",
            countLabel: "—",
            body: "打开熊舍管家同步任务"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayTasksEntry) -> Void) {
        completion(loadEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayTasksEntry>) -> Void) {
        let entry = loadEntry()
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private func loadEntry() -> TodayTasksEntry {
        // Prefer App Group once the Widget Extension target is linked.
        let defaults = UserDefaults(suiteName: "group.cn.scolvpet.dev") ?? .standard
        let headline = defaults.string(forKey: "today_widget_title") ?? "今日待办"
        let count = defaults.string(forKey: "today_widget_count_label") ?? "—"
        let body = defaults.string(forKey: "today_widget_body") ?? "打开熊舍管家同步任务"
        return TodayTasksEntry(
            date: Date(),
            headline: headline,
            countLabel: count,
            body: body
        )
    }
}

struct TodayTasksWidgetEntryView: View {
    var entry: TodayTasksEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(entry.headline)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(entry.countLabel)
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(red: 0.78, green: 0.47, blue: 0.32))
                    .clipShape(Capsule())
                    .foregroundStyle(.white)
            }
            Text(entry.body)
                .font(.caption)
                .foregroundStyle(Color(red: 0.91, green: 0.93, blue: 0.93))
                .lineLimit(6)
            Spacer(minLength: 0)
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(red: 0.17, green: 0.21, blue: 0.20)
        }
    }
}

struct TodayTasksWidget: Widget {
    let kind = "TodayTasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayTasksProvider()) { entry in
            TodayTasksWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("今日待办")
        .description("显示今日护理待办与逾期任务")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
