import Foundation
import Combine

final class LettersViewModel: ObservableObject {
    @Published private(set) var letters: [Letter] = []

    private let store: LetterStore
    private let notifications: NotificationManager

    init(store: LetterStore = LetterStore(), notifications: NotificationManager = .shared) {
        self.store = store
        self.notifications = notifications
        let loaded = store.load()
        letters = loaded.isEmpty ? LettersViewModel.seed() : loaded
        if loaded.isEmpty { persist() }
        notifications.requestAuthorization()
    }

    var sealed: [Letter] {
        letters.filter { $0.isSealed }.sorted { $0.unlockAt < $1.unlockAt }
    }

    var ready: [Letter] {
        letters.filter { !$0.isSealed && !$0.isOpened }.sorted { $0.unlockAt > $1.unlockAt }
    }

    var opened: [Letter] {
        letters.filter { $0.isOpened }.sorted { $0.unlockAt > $1.unlockAt }
    }

    var featured: [Letter] {
        Array(letters.sorted { $0.unlockAt < $1.unlockAt }.prefix(4))
    }

    var totalCount: Int { letters.count }
    var sealedCount: Int { letters.filter { $0.isSealed }.count }
    var openedCount: Int { letters.filter { $0.isOpened }.count }
    var readyCount: Int { ready.count }

    var nextUnlock: Letter? { sealed.first }

    var longestWaitDays: Int {
        letters.map { Calendar.current.dateComponents([.day], from: $0.createdAt, to: $0.unlockAt).day ?? 0 }.max() ?? 0
    }

    func letter(with id: UUID) -> Letter? {
        letters.first { $0.id == id }
    }

    func add(_ letter: Letter) {
        letters.append(letter)
        persist()
        notifications.schedule(for: letter)
    }

    func update(_ letter: Letter) {
        guard let index = letters.firstIndex(where: { $0.id == letter.id }) else { return }
        letters[index] = letter
        persist()
        notifications.cancel(for: letter)
        notifications.schedule(for: letter)
    }

    func delete(_ letter: Letter) {
        letters.removeAll { $0.id == letter.id }
        persist()
        notifications.cancel(for: letter)
    }

    func deleteAll() {
        letters.removeAll()
        persist()
        notifications.cancelAll()
    }

    func open(_ letter: Letter) {
        guard let index = letters.firstIndex(where: { $0.id == letter.id }) else { return }
        letters[index].isOpened = true
        persist()
    }

    func toggleFavorite(_ letter: Letter) {
        guard let index = letters.firstIndex(where: { $0.id == letter.id }) else { return }
        letters[index].isFavorite.toggle()
        persist()
    }

    private func persist() {
        store.save(letters)
    }

    private static func seed() -> [Letter] {
        let calendar = Calendar.current
        func date(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: days, to: Date()) ?? Date()
        }
        return [
            Letter(title: "Birthday in a year",
                   recipient: "Future Me",
                   message: "Remember why you started. Stay curious.",
                   unlockAt: date(240),
                   accent: .amber,
                   category: .birthday,
                   isFavorite: true),
            Letter(title: "Graduation day",
                   recipient: "Future Me",
                   message: "You made it through the hardest part.",
                   unlockAt: date(120),
                   accent: .violet,
                   category: .goals),
            Letter(title: "Note to Alex",
                   recipient: "Alex",
                   message: "By the time you read this, everything changed.",
                   unlockAt: date(45),
                   accent: .teal,
                   category: .friends),
            Letter(title: "New Year message",
                   recipient: "Future Me",
                   message: "Did the resolutions survive?",
                   unlockAt: date(-3),
                   accent: .rose,
                   isOpened: false,
                   category: .personal),
            Letter(title: "Summer memory",
                   recipient: "Future Me",
                   message: "The trip was worth every mile.",
                   unlockAt: date(-20),
                   accent: .ocean,
                   isOpened: true,
                   category: .memories)
        ]
    }
}
