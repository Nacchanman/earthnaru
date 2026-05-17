import SwiftUI

struct CompanionView: View {
    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { context in
            let mood = TimeMood(date: context.date)

            VStack(spacing: 6) {
                MascotView(date: context.date, mood: mood)
                    .frame(width: 138, height: 156)

                PixelClockView(time: Self.timeFormatter.string(from: context.date), color: mood.textColor)
            }
            .padding(.top, 10)
            .padding(.horizontal, 10)
            .padding(.bottom, 9)
            .frame(width: 172, height: 214)
            .background(mood.background)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(.white.opacity(mood.borderOpacity), lineWidth: 1)
            )
        }
    }
}

private struct PixelClockView: View {
    let time: String
    let color: Color

    private let pixel: CGFloat = 4

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(time.enumerated()), id: \.offset) { _, character in
                PixelGrid(rows: rows(for: character), pixelSize: pixel, color: color)
            }
        }
        .frame(height: 28)
        .accessibilityLabel(time)
    }

    private func rows(for character: Character) -> [String] {
        switch character {
        case "0": return ["111", "1.1", "1.1", "1.1", "111"]
        case "1": return [".1.", "11.", ".1.", ".1.", "111"]
        case "2": return ["111", "..1", "111", "1..", "111"]
        case "3": return ["111", "..1", ".11", "..1", "111"]
        case "4": return ["1.1", "1.1", "111", "..1", "..1"]
        case "5": return ["111", "1..", "111", "..1", "111"]
        case "6": return ["111", "1..", "111", "1.1", "111"]
        case "7": return ["111", "..1", ".1.", ".1.", ".1."]
        case "8": return ["111", "1.1", "111", "1.1", "111"]
        case "9": return ["111", "1.1", "111", "..1", "111"]
        case ":": return [".", "1", ".", "1", "."]
        default: return ["...", "...", "...", "...", "..."]
        }
    }
}

private struct PixelGrid: View {
    let rows: [String]
    let pixelSize: CGFloat
    let color: Color

    var body: some View {
        ZStack(alignment: .topLeading) {
            ForEach(Array(rows.enumerated()), id: \.offset) { rowIndex, row in
                ForEach(Array(Array(row).enumerated()), id: \.offset) { columnIndex, symbol in
                    if symbol != "." {
                        Rectangle()
                            .fill(color)
                            .frame(width: pixelSize, height: pixelSize)
                            .offset(
                                x: CGFloat(columnIndex) * pixelSize,
                                y: CGFloat(rowIndex) * pixelSize
                            )
                    }
                }
            }
        }
        .frame(
            width: CGFloat(rows.map { $0.count }.max() ?? 0) * pixelSize,
            height: CGFloat(rows.count) * pixelSize,
            alignment: .topLeading
        )
    }
}

enum TimeMood {
    case dawn
    case morning
    case noon
    case afternoon
    case evening
    case night
    case lateNight

    init(date: Date, calendar: Calendar = .current) {
        let hour = calendar.component(.hour, from: date)

        switch hour {
        case 5..<8:
            self = .dawn
        case 8..<11:
            self = .morning
        case 11..<14:
            self = .noon
        case 14..<18:
            self = .afternoon
        case 18..<22:
            self = .evening
        case 22..<24:
            self = .night
        default:
            self = .lateNight
        }
    }

    var textColor: Color {
        switch self {
        case .dawn: return Color(red: 0.35, green: 0.24, blue: 0.42)
        case .morning: return Color(red: 0.08, green: 0.28, blue: 0.42)
        case .noon: return Color(red: 0.10, green: 0.32, blue: 0.22)
        case .afternoon: return Color(red: 0.09, green: 0.27, blue: 0.43)
        case .evening: return Color(red: 0.34, green: 0.18, blue: 0.36)
        case .night: return Color(red: 0.78, green: 0.85, blue: 1.00)
        case .lateNight: return Color(red: 0.70, green: 0.82, blue: 1.00)
        }
    }

    var borderOpacity: Double {
        switch self {
        case .night, .lateNight: return 0.16
        default: return 0.36
        }
    }

    var background: some ShapeStyle {
        LinearGradient(colors: backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    private var backgroundColors: [Color] {
        switch self {
        case .dawn:
            return [
                Color(red: 0.98, green: 0.76, blue: 0.62).opacity(0.92),
                Color(red: 0.82, green: 0.88, blue: 0.98).opacity(0.92)
            ]
        case .morning:
            return [
                Color(red: 0.76, green: 0.91, blue: 0.98).opacity(0.93),
                Color(red: 0.89, green: 0.96, blue: 0.78).opacity(0.93)
            ]
        case .noon:
            return [
                Color(red: 0.62, green: 0.86, blue: 1.00).opacity(0.93),
                Color(red: 0.98, green: 0.92, blue: 0.62).opacity(0.93)
            ]
        case .afternoon:
            return [
                Color(red: 0.80, green: 0.91, blue: 1.00).opacity(0.93),
                Color(red: 0.74, green: 0.93, blue: 0.83).opacity(0.93)
            ]
        case .evening:
            return [
                Color(red: 0.96, green: 0.58, blue: 0.47).opacity(0.92),
                Color(red: 0.45, green: 0.46, blue: 0.84).opacity(0.92)
            ]
        case .night:
            return [
                Color(red: 0.09, green: 0.12, blue: 0.27).opacity(0.94),
                Color(red: 0.16, green: 0.24, blue: 0.44).opacity(0.94)
            ]
        case .lateNight:
            return [
                Color(red: 0.04, green: 0.07, blue: 0.17).opacity(0.95),
                Color(red: 0.13, green: 0.16, blue: 0.34).opacity(0.95)
            ]
        }
    }
}
