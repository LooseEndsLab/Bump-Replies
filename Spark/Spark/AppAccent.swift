import SwiftUI

enum AppAccent: String, CaseIterable, Identifiable {
    case warmAmber
    case blue
    case purple
    case green

    var id: Self { self }

    var title: String {
        switch self {
        case .warmAmber: "Warm Amber"
        case .blue: "Blue"
        case .purple: "Purple"
        case .green: "Green"
        }
    }

    var color: Color {
        switch self {
        case .warmAmber: Color(red: 0.788, green: 0.365, blue: 0.102)
        case .blue: .blue
        case .purple: .purple
        case .green: .green
        }
    }
}
