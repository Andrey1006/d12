import SwiftUI

enum LetterAccent: String, Codable, CaseIterable, Identifiable {
    case amber
    case violet
    case teal
    case rose
    case ocean

    var id: String { rawValue }

    var colors: [Color] {
        switch self {
        case .amber:
            return [Color(red: 1.0, green: 0.55, blue: 0.1), Color(red: 0.5, green: 0.15, blue: 0.05)]
        case .violet:
            return [Color(red: 0.55, green: 0.3, blue: 0.9), Color(red: 0.2, green: 0.1, blue: 0.4)]
        case .teal:
            return [Color(red: 0.1, green: 0.7, blue: 0.68), Color(red: 0.05, green: 0.25, blue: 0.35)]
        case .rose:
            return [Color(red: 0.95, green: 0.35, blue: 0.5), Color(red: 0.4, green: 0.1, blue: 0.25)]
        case .ocean:
            return [Color(red: 0.2, green: 0.5, blue: 0.95), Color(red: 0.08, green: 0.15, blue: 0.4)]
        }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

enum LetterCategory: String, Codable, CaseIterable, Identifiable {
    case personal
    case birthday
    case goals
    case friends
    case memories

    var id: String { rawValue }

    var title: String {
        switch self {
        case .personal: return "Personal"
        case .birthday: return "Birthday"
        case .goals: return "Goals"
        case .friends: return "Friends"
        case .memories: return "Memories"
        }
    }

    var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .birthday: return "gift.fill"
        case .goals: return "target"
        case .friends: return "heart.fill"
        case .memories: return "sparkles"
        }
    }
}

struct Letter: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var recipient: String
    var message: String
    var createdAt: Date
    var unlockAt: Date
    var accent: LetterAccent
    var isOpened: Bool
    var photoData: Data?
    var category: LetterCategory
    var isFavorite: Bool

    init(id: UUID = UUID(),
         title: String,
         recipient: String,
         message: String,
         createdAt: Date = Date(),
         unlockAt: Date,
         accent: LetterAccent = .amber,
         isOpened: Bool = false,
         photoData: Data? = nil,
         category: LetterCategory = .personal,
         isFavorite: Bool = false) {
        self.id = id
        self.title = title
        self.recipient = recipient
        self.message = message
        self.createdAt = createdAt
        self.unlockAt = unlockAt
        self.accent = accent
        self.isOpened = isOpened
        self.photoData = photoData
        self.category = category
        self.isFavorite = isFavorite
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        recipient = try container.decode(String.self, forKey: .recipient)
        message = try container.decode(String.self, forKey: .message)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        unlockAt = try container.decode(Date.self, forKey: .unlockAt)
        accent = try container.decode(LetterAccent.self, forKey: .accent)
        isOpened = try container.decodeIfPresent(Bool.self, forKey: .isOpened) ?? false
        photoData = try container.decodeIfPresent(Data.self, forKey: .photoData)
        category = try container.decodeIfPresent(LetterCategory.self, forKey: .category) ?? .personal
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }

    var isSealed: Bool { Date() < unlockAt }

    var hasPhoto: Bool { photoData != nil }

    var daysRemaining: Int {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.startOfDay(for: unlockAt)
        return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
    }

    var unlockDateText: String {
        unlockAt.formatted(date: .abbreviated, time: .omitted)
    }
}
