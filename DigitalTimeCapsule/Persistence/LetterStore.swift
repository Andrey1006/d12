import Foundation

final class LetterStore {
    private let key = "letters.storage.v1"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [Letter] {
        guard let data = defaults.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode([Letter].self, from: data)) ?? []
    }

    func save(_ letters: [Letter]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(letters) else { return }
        defaults.set(data, forKey: key)
    }
}
