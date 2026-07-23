import SwiftUI
import WidgetKit

private let widgetGroupId = "group.com.trilha.trilhaApp"

struct TrilhaEntry: TimelineEntry {
  let date: Date
  let streak: Int
  let streakLabel: String
  let progressLabel: String
  let statusLine: String
  let goalMet: Bool
  let streakAtRisk: Bool
  let dailyGoal: Int
  let missionsDone: Int
}

struct TrilhaProvider: TimelineProvider {
  func placeholder(in context: Context) -> TrilhaEntry {
    TrilhaEntry(
      date: Date(),
      streak: 7,
      streakLabel: "7 dias",
      progressLabel: "1/1 missões",
      statusLine: "Meta de hoje concluída",
      goalMet: true,
      streakAtRisk: false,
      dailyGoal: 1,
      missionsDone: 1
    )
  }

  private func readEntry() -> TrilhaEntry {
    let data = UserDefaults(suiteName: widgetGroupId)
    let streak = data?.integer(forKey: "streak") ?? 0
    let goal = max(data?.integer(forKey: "daily_goal") ?? 1, 1)
    let done = max(data?.integer(forKey: "missions_done") ?? 0, 0)
    return TrilhaEntry(
      date: Date(),
      streak: streak,
      streakLabel: data?.string(forKey: "streak_label") ?? "0 dias",
      progressLabel: data?.string(forKey: "progress_label") ?? "0/\(goal) missões",
      statusLine: data?.string(forKey: "status_line") ?? "Abra o Stway",
      goalMet: data?.bool(forKey: "goal_met") ?? false,
      streakAtRisk: data?.bool(forKey: "streak_at_risk") ?? false,
      dailyGoal: goal,
      missionsDone: done
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (TrilhaEntry) -> Void) {
    completion(readEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TrilhaEntry>) -> Void) {
    let entry = readEntry()
    let midnight = Calendar.current.startOfDay(
      for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    )
    completion(Timeline(entries: [entry], policy: .after(midnight)))
  }
}

struct TrilhaHomeWidgetEntryView: View {
  var entry: TrilhaProvider.Entry

  private var progress: Double {
    guard entry.dailyGoal > 0 else { return 0 }
    return min(Double(entry.missionsDone) / Double(entry.dailyGoal), 1)
  }

  private var statusColor: Color {
    if entry.goalMet { return Color(red: 0.77, green: 0.47, blue: 0.24) }
    if entry.streakAtRisk { return Color(red: 0.88, green: 0.44, blue: 0.25) }
    return Color(red: 0.60, green: 0.64, blue: 0.61)
  }

  var body: some View {
    ZStack {
      LinearGradient(
        colors: [
          Color(red: 0.14, green: 0.25, blue: 0.21),
          Color(red: 0.08, green: 0.16, blue: 0.13),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )

      VStack(alignment: .leading, spacing: 0) {
        HStack {
          Text("STWAY")
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .kerning(1.4)
            .foregroundStyle(Color(red: 0.60, green: 0.64, blue: 0.61))

          Spacer()

          if entry.streakAtRisk && !entry.goalMet {
            Text("Em risco")
              .font(.system(size: 10, weight: .bold, design: .rounded))
              .foregroundStyle(Color(red: 0.88, green: 0.44, blue: 0.25))
              .padding(.horizontal, 8)
              .padding(.vertical, 3)
              .background(Color(red: 0.88, green: 0.44, blue: 0.25).opacity(0.15))
              .clipShape(RoundedRectangle(cornerRadius: 6))
          }
        }

        HStack(alignment: .lastTextBaseline, spacing: 6) {
          Text("\(entry.streak)")
            .font(.system(size: 42, weight: .bold, design: .rounded))
            .foregroundStyle(Color(red: 0.88, green: 0.44, blue: 0.25))
          Text(entry.streakLabel)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(Color(red: 0.91, green: 0.90, blue: 0.88))
        }
        .padding(.top, 4)

        Text(entry.progressLabel)
          .font(.system(size: 13, weight: .medium, design: .rounded))
          .foregroundStyle(Color(red: 0.91, green: 0.90, blue: 0.88))
          .padding(.top, 8)

        GeometryReader { geo in
          ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 3)
              .fill(Color.white.opacity(0.08))
            RoundedRectangle(cornerRadius: 3)
              .fill(Color(red: 0.77, green: 0.47, blue: 0.24))
              .frame(width: geo.size.width * progress)
          }
        }
        .frame(height: 6)
        .padding(.top, 6)

        Text(entry.statusLine)
          .font(.system(size: 12, weight: .regular, design: .rounded))
          .foregroundStyle(statusColor)
          .padding(.top, 8)

        Spacer(minLength: 0)
      }
      .padding(14)
    }
    .widgetURL(URL(string: "trilha://home"))
  }
}

@main
struct TrilhaHomeWidget: Widget {
  let kind: String = "TrilhaHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: TrilhaProvider()) { entry in
      if #available(iOSApplicationExtension 17.0, *) {
        TrilhaHomeWidgetEntryView(entry: entry)
          .containerBackground(for: .widget) {
            Color(red: 0.08, green: 0.16, blue: 0.13)
          }
      } else {
        TrilhaHomeWidgetEntryView(entry: entry)
      }
    }
    .configurationDisplayName("STWAY")
    .description("Sua sequência e meta diária.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct TrilhaHomeWidget_Previews: PreviewProvider {
  static var previews: some View {
    TrilhaHomeWidgetEntryView(
      entry: TrilhaEntry(
        date: Date(),
        streak: 12,
        streakLabel: "12 dias",
        progressLabel: "0/1 missões",
        statusLine: "Falta 1 missão",
        goalMet: false,
        streakAtRisk: true,
        dailyGoal: 1,
        missionsDone: 0
      )
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
