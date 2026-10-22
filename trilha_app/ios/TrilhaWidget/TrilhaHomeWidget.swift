import SwiftUI
import WidgetKit

private let widgetGroupId = "group.ZS7LYV9Y7U.stway"
private let dayLength: TimeInterval = 24 * 60 * 60

/// Card da sequência. O app grava o estado do dia (`card_*`); aqui ele vira
/// o card e, se o app não abrir, a timeline vira o dia à meia-noite.
struct TrilhaEntry: TimelineEntry {
  let date: Date
  let streak: Int
  /// risk | start | safe | away
  let state: String
  let headline: String
  let big: String
  let sub: String
  let deadline: Date

  var counts: Bool { state == "risk" || state == "start" }
  var warm: Bool { counts }
}

private struct StoredCard {
  let streak: Int
  let state: String
  let dayEnd: Date
  let headline: String
  let big: String
  let sub: String
  let nextHeadline: String
  let nextSub: String
  let awayHeadline: String
  let awayBig: String
  let awaySub: String

  static func read() -> StoredCard {
    let data = UserDefaults(suiteName: widgetGroupId)
    let ms = (data?.object(forKey: "card_day_end") as? NSNumber)?.doubleValue ?? 0
    func text(_ key: String, _ fallback: String = "") -> String {
      data?.string(forKey: key) ?? fallback
    }
    let headline = text("card_headline", "Stway")
    let big = text("card_big")
    let sub = text("card_sub")
    return StoredCard(
      streak: data?.integer(forKey: "streak") ?? 0,
      state: text("card_state", "start"),
      dayEnd: Date(timeIntervalSince1970: ms / 1000),
      headline: headline,
      big: big,
      sub: sub,
      nextHeadline: text("card_next_headline", headline),
      nextSub: text("card_next_sub", sub),
      awayHeadline: text("card_away_headline", headline),
      awayBig: text("card_away_big", big),
      awaySub: text("card_away_sub", sub)
    )
  }

  /// Estado gravado pelo app, avançado para [now] se o dia já virou.
  func entry(at now: Date) -> TrilhaEntry {
    let nextMidnight = Calendar.current.startOfDay(
      for: Calendar.current.date(byAdding: .day, value: 1, to: now) ?? now
    )
    func make(_ state: String, _ headline: String, _ big: String, _ sub: String, _ deadline: Date)
      -> TrilhaEntry
    {
      TrilhaEntry(
        date: now, streak: streak, state: state, headline: headline, big: big, sub: sub,
        deadline: deadline)
    }
    if now < dayEnd { return make(state, headline, big, sub, dayEnd) }
    if state == "safe" && now < dayEnd.addingTimeInterval(dayLength) {
      return make("risk", nextHeadline, "", nextSub, nextMidnight)
    }
    if state == "start" { return make(state, headline, big, sub, nextMidnight) }
    return make("away", awayHeadline, awayBig, awaySub, nextMidnight)
  }
}

struct TrilhaProvider: TimelineProvider {
  func placeholder(in context: Context) -> TrilhaEntry {
    TrilhaEntry(
      date: Date(),
      streak: 12,
      state: "risk",
      headline: "Mantenha sua sequência",
      big: "",
      sub: "12 dias seguidos · falta 1 cena",
      deadline: Date().addingTimeInterval(12 * 60 * 60)
    )
  }

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

  private var sub: some View {
    Text(entry.sub)
      .font(.system(size: 12, weight: .medium, design: .rounded))
      .foregroundStyle(Color.white.opacity(0.9))
      .lineLimit(1)
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
      VStack(alignment: .leading, spacing: 4) {
        HStack(alignment: .top) {
          pill
          Spacer(minLength: 0)
          Image(anan).resizable().scaledToFit().frame(width: 52, height: 52)
            .padding(.top, -10)
        }
        Spacer(minLength: 0)
        headline
        main(size: 26)
      }
    } else {
      HStack(spacing: 6) {
        VStack(alignment: .leading, spacing: 4) {
          HStack(spacing: 8) {
            pill
            headline
          }
          main(size: 38)
          sub
        }
        Spacer(minLength: 0)
        Image(anan).resizable().scaledToFit().frame(width: 96, height: 96)
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
    .description("Sua sequência e o tempo que falta para caminhar hoje.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}

struct TrilhaHomeWidget_Previews: PreviewProvider {
  static var previews: some View {
    TrilhaHomeWidgetEntryView(
      entry: TrilhaEntry(
        date: Date(),
        streak: 12,
        state: "risk",
        headline: "Mantenha sua sequência",
        big: "",
        sub: "12 dias seguidos · falta 1 cena",
        deadline: Date().addingTimeInterval(12 * 60 * 60)
      ),
      padded: true
    )
    .previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
