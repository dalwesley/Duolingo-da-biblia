import SwiftUI
import WidgetKit

private let widgetGroupId = "group.ZS7LYV9Y7U.stway"
private let dayLength: TimeInterval = 24 * 60 * 60

/// Marca de um dia na faixa da semana.
enum DayMark { case done, frozen, today, missed, later }

/// Card da sequência. O app grava o estado do dia (`card_*`); aqui ele vira
/// o card e, se o app não abrir, a timeline vira o dia à meia-noite.
struct TrilhaEntry: TimelineEntry {
  let date: Date
  let streak: Int
  /// risk | start | safe | away
  let state: String
  let headline: String
  let big: String
  /// Linha curta do tamanho pequeno ("Feito hoje"), vazia quando há contagem.
  let short: String
  let deadline: Date
  /// Segunda a domingo da semana de [date].
  let week: [DayMark]
  let labels: [String]

  var counts: Bool { state == "risk" || state == "start" }
  var warm: Bool { counts }
}

private struct StoredCard {
  let streak: Int
  let state: String
  let dayEnd: Date
  let headline: String
  let big: String
  let short: String
  let nextHeadline: String
  let awayHeadline: String
  let awayBig: String
  let awayShort: String
  let played: Set<String>
  let frozen: Set<String>
  let labels: [String]

  static func read() -> StoredCard {
    let data = UserDefaults(suiteName: widgetGroupId)
    let ms = (data?.object(forKey: "card_day_end") as? NSNumber)?.doubleValue ?? 0
    func text(_ key: String, _ fallback: String = "") -> String {
      data?.string(forKey: key) ?? fallback
    }
    func days(_ key: String) -> Set<String> {
      Set(text(key).split(separator: ",").map(String.init))
    }
    let headline = text("card_headline", "Stway")
    let big = text("card_big")
    let short = text("card_short")
    return StoredCard(
      streak: data?.integer(forKey: "streak") ?? 0,
      state: text("card_state", "start"),
      dayEnd: Date(timeIntervalSince1970: ms / 1000),
      headline: headline,
      big: big,
      short: short,
      nextHeadline: text("card_next_headline", headline),
      awayHeadline: text("card_away_headline", headline),
      awayBig: text("card_away_big", big),
      awayShort: text("card_away_short", short),
      played: days("played_days"),
      frozen: days("frozen_days"),
      labels: text("week_labels", "S,T,Q,Q,S,S,D").split(separator: ",").map(String.init)
    )
  }

  /// Segunda a domingo da semana de [now], marcados pelas datas do app.
  func week(at now: Date) -> [DayMark] {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = .current
    let format = DateFormatter()
    format.calendar = calendar
    format.locale = Locale(identifier: "en_US_POSIX")
    format.dateFormat = "yyyy-MM-dd"
    let today = calendar.startOfDay(for: now)
    let back = (calendar.component(.weekday, from: today) + 5) % 7
    let monday = calendar.date(byAdding: .day, value: -back, to: today) ?? today
    return (0..<7).map { offset in
      let day = calendar.date(byAdding: .day, value: offset, to: monday) ?? monday
      let key = format.string(from: day)
      if played.contains(key) { return .done }
      if frozen.contains(key) { return .frozen }
      if day == today { return .today }
      return day < today ? .missed : .later
    }
  }

  /// Estado gravado pelo app, avançado para [now] se o dia já virou.
  func entry(at now: Date) -> TrilhaEntry {
    let nextMidnight = Calendar.current.startOfDay(
      for: Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
    )
    func make(
      _ state: String, _ headline: String, _ big: String, _ short: String, _ deadline: Date
    ) -> TrilhaEntry {
      TrilhaEntry(
        date: now, streak: streak, state: state, headline: headline, big: big, short: short,
        deadline: deadline, week: week(at: now), labels: labels)
    }
    if now < dayEnd { return make(state, headline, big, short, dayEnd) }
    if state == "safe" && now < dayEnd.addingTimeInterval(dayLength) {
      return make("risk", nextHeadline, "", "", nextMidnight)
    }
    if state == "start" { return make(state, headline, big, short, nextMidnight) }
    return make("away", awayHeadline, awayBig, awayShort, nextMidnight)
  }
}

extension TrilhaEntry {
  static var sample: TrilhaEntry {
    TrilhaEntry(
      date: Date(),
      streak: 12,
      state: "risk",
      headline: "Mantenha sua sequência",
      big: "",
      short: "",
      deadline: Date().addingTimeInterval(12 * 60 * 60),
      week: [.done, .done, .done, .today, .later, .later, .later],
      labels: ["S", "T", "Q", "Q", "S", "S", "D"]
    )
  }
}

struct TrilhaProvider: TimelineProvider {
  func placeholder(in context: Context) -> TrilhaEntry { .sample }

  func getSnapshot(in context: Context, completion: @escaping (TrilhaEntry) -> Void) {
    if context.isPreview {
      completion(placeholder(in: context))
      return
    }
    completion(StoredCard.read().entry(at: Date()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TrilhaEntry>) -> Void) {
    let card = StoredCard.read()
    let now = Date()
    let first = card.entry(at: now)
    // Logo após o prazo o card muda sozinho (garantida → em risco, ou dia
    // perdido); depois disso a timeline pede outra.
    let rollover = card.entry(at: first.deadline.addingTimeInterval(1))
    completion(Timeline(entries: [first, rollover], policy: .after(rollover.deadline)))
  }
}

private enum Palette {
  static let warmStart = Color(red: 0.914, green: 0.475, blue: 0.353)
  static let warmEnd = Color(red: 0.965, green: 0.718, blue: 0.518)
  static let warmInk = Color(red: 0.851, green: 0.388, blue: 0.290)
  static let nightStart = Color(red: 0.106, green: 0.227, blue: 0.361)
  static let nightEnd = Color(red: 0.047, green: 0.102, blue: 0.173)
  static let accent = Color(red: 0.969, green: 0.733, blue: 0.004)
  static let nightInk = Color(red: 0.047, green: 0.102, blue: 0.173)
  static let ice = Color(red: 0.624, green: 0.847, blue: 1.0)

  static func background(warm: Bool) -> LinearGradient {
    warm
      ? LinearGradient(colors: [warmStart, warmEnd], startPoint: .leading, endPoint: .trailing)
      : LinearGradient(
        colors: [nightStart, nightEnd], startPoint: .topLeading, endPoint: .bottomTrailing)
  }
}

struct TrilhaHomeWidgetEntryView: View {
  var entry: TrilhaProvider.Entry
  /// Antes do iOS 17 o widget não tem margem própria.
  var padded: Bool

  @Environment(\.widgetFamily) private var family

  private var anan: String {
    entry.state == "safe" ? "widget_anan_sucesso" : "widget_anan_triste"
  }

  private var pill: some View {
    HStack(spacing: 2) {
      Image(systemName: "flame.fill").font(.system(size: 11, weight: .bold))
      Text("\(entry.streak)").font(.system(size: 13, weight: .bold, design: .rounded))
    }
    .foregroundStyle(entry.warm ? Palette.warmInk : Palette.accent)
    .padding(.horizontal, 8)
    .padding(.vertical, 2)
    .background(Capsule().fill(Color.white.opacity(entry.warm ? 0.95 : 0.15)))
  }

  private var headline: some View {
    Text(entry.headline.uppercased())
      .font(.system(size: 11, weight: .bold, design: .rounded))
      .kerning(0.6)
      .foregroundStyle(.white)
      .lineLimit(2)
      .fixedSize(horizontal: false, vertical: true)
  }

  @ViewBuilder private func main(size: CGFloat) -> some View {
    if entry.counts {
      Text(entry.deadline, style: .timer)
        .font(.system(size: size, weight: .heavy, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(.white)
        .lineLimit(1)
        .minimumScaleFactor(0.6)
    } else {
      Text(entry.big)
        .font(.system(size: size * 0.5, weight: .bold, design: .rounded))
        .foregroundStyle(.white)
        .lineLimit(2)
    }
  }

  /// 🔥 grande do tamanho pequeno.
  private var count: some View {
    HStack(spacing: 3) {
      Image(systemName: "flame.fill").font(.system(size: 22, weight: .bold))
      Text("\(entry.streak)").font(.system(size: 28, weight: .heavy, design: .rounded))
    }
    .foregroundStyle(entry.warm ? Color.white : Palette.accent)
    .lineLimit(1)
    .minimumScaleFactor(0.6)
  }

  @ViewBuilder private var shortLine: some View {
    if entry.counts {
      Text(entry.deadline, style: .timer)
        .font(.system(size: 15, weight: .bold, design: .rounded))
        .monospacedDigit()
        .foregroundStyle(.white)
        .lineLimit(1)
    } else if !entry.short.isEmpty {
      Text(entry.short)
        .font(.system(size: 13, weight: .bold, design: .rounded))
        .foregroundStyle(Color.white.opacity(0.9))
        .lineLimit(1)
    }
  }

  private var weekStrip: some View {
    HStack(spacing: 0) {
      ForEach(0..<7, id: \.self) { i in
        let mark = i < entry.week.count ? entry.week[i] : .later
        VStack(spacing: 3) {
          Text(i < entry.labels.count ? entry.labels[i] : "")
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(Color.white.opacity(mark == .done || mark == .today ? 1 : 0.7))
          dot(mark)
        }
        .frame(maxWidth: .infinity)
      }
    }
  }

  @ViewBuilder private func dot(_ mark: DayMark) -> some View {
    let size: CGFloat = 18
    switch mark {
    case .done, .frozen:
      ZStack {
        Circle().fill(
          mark == .frozen ? Palette.ice : (entry.warm ? Color.white.opacity(0.95) : Palette.accent))
        Image(systemName: "checkmark")
          .font(.system(size: 9, weight: .heavy))
          .foregroundStyle(mark == .done && entry.warm ? Palette.warmInk : Palette.nightInk)
      }
      .frame(width: size, height: size)
    case .today:
      Circle().stroke(Color.white, lineWidth: 2).frame(width: size - 2, height: size - 2)
        .frame(width: size, height: size)
    case .missed, .later:
      Circle().fill(Color.white.opacity(0.2)).frame(width: size, height: size)
    }
  }

  var body: some View {
    ZStack {
      if padded { Palette.background(warm: entry.warm) }
      content.padding(padded ? 16 : 0)
    }
    .widgetURL(URL(string: "stway://hoje"))
  }

  @ViewBuilder private var content: some View {
    if family == .systemSmall {
      VStack(alignment: .leading, spacing: 2) {
        count
        shortLine
        Spacer(minLength: 0)
        HStack {
          Spacer(minLength: 0)
          Image(anan).resizable().scaledToFit().frame(width: 84, height: 84)
            .padding(.bottom, -8)
            .padding(.trailing, -6)
        }
      }
    } else {
      HStack(spacing: 6) {
        VStack(alignment: .leading, spacing: 6) {
          HStack(spacing: 8) {
            pill
            headline
          }
          main(size: 34)
          weekStrip
        }
        Spacer(minLength: 0)
        Image(anan).resizable().scaledToFit().frame(width: 92, height: 92)
      }
    }
  }
}

@main
struct TrilhaHomeWidget: Widget {
  let kind: String = "TrilhaHomeWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: TrilhaProvider()) { entry in
      if #available(iOSApplicationExtension 17.0, *) {
        TrilhaHomeWidgetEntryView(entry: entry, padded: false)
          .containerBackground(for: .widget) {
            Palette.background(warm: entry.warm)
          }
      } else {
        TrilhaHomeWidgetEntryView(entry: entry, padded: true)
      }
    }
    .configurationDisplayName("STWAY")
    .description("Sua sequência, a semana e o tempo que falta para caminhar hoje.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct TrilhaHomeWidget_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TrilhaHomeWidgetEntryView(entry: .sample, padded: true)
        .previewContext(WidgetPreviewContext(family: .systemSmall))
      TrilhaHomeWidgetEntryView(entry: .sample, padded: true)
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
  }
}
