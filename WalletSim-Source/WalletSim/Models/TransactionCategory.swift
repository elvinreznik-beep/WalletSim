import SwiftUI

enum TransactionCategory: String, CaseIterable, Identifiable {
    case shopping
    case fashion
    case restaurant
    case groceries
    case cafe
    case travel
    case hotel
    case transport
    case fuel
    case entertainment
    case gaming
    case tech
    case gifts
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .shopping: "Shopping"
        case .fashion: "Mode"
        case .restaurant: "Restaurant"
        case .groceries: "Lebensmittel"
        case .cafe: "Café"
        case .travel: "Reisen"
        case .hotel: "Hotel"
        case .transport: "Mobilität"
        case .fuel: "Tanken"
        case .entertainment: "Freizeit"
        case .gaming: "Gaming"
        case .tech: "Technik"
        case .gifts: "Geschenke"
        case .other: "Sonstiges"
        }
    }

    var symbol: String {
        switch self {
        case .shopping: "bag.fill"
        case .fashion: "tshirt.fill"
        case .restaurant: "fork.knife"
        case .groceries: "cart.fill"
        case .cafe: "cup.and.saucer.fill"
        case .travel: "airplane"
        case .hotel: "bed.double.fill"
        case .transport: "car.fill"
        case .fuel: "fuelpump.fill"
        case .entertainment: "film.fill"
        case .gaming: "gamecontroller.fill"
        case .tech: "laptopcomputer"
        case .gifts: "gift.fill"
        case .other: "creditcard.fill"
        }
    }

    var color: Color {
        switch self {
        case .shopping: Color(hex: "#FF9F0A")
        case .fashion: Color(hex: "#FF375F")
        case .restaurant: Color(hex: "#FF6B3D")
        case .groceries: Color(hex: "#30D158")
        case .cafe: Color(hex: "#A2845E")
        case .travel: Color(hex: "#0A84FF")
        case .hotel: Color(hex: "#5E5CE6")
        case .transport: Color(hex: "#64D2FF")
        case .fuel: Color(hex: "#FFD60A")
        case .entertainment: Color(hex: "#BF5AF2")
        case .gaming: Color(hex: "#32D74B")
        case .tech: Color(hex: "#8E8E93")
        case .gifts: Color(hex: "#FF2D55")
        case .other: Color(hex: "#636366")
        }
    }
}
