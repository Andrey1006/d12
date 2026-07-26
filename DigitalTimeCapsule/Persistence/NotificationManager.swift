import Foundation
import UserNotifications

enum NotificationSettingsKey {
    static let enabled = "settings.notificationsEnabled"
    static let sound = "settings.notificationSound"
}

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    private var isEnabled: Bool {
        UserDefaults.standard.object(forKey: NotificationSettingsKey.enabled) as? Bool ?? true
    }

    private var soundEnabled: Bool {
        UserDefaults.standard.object(forKey: NotificationSettingsKey.sound) as? Bool ?? true
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func schedule(for letter: Letter) {
        guard isEnabled, letter.unlockAt > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "A letter just unlocked"
        content.body = "\"\(letter.title)\" is ready to open."
        content.sound = soundEnabled ? .default : nil

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: letter.unlockAt)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: letter.id.uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancel(for letter: Letter) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [letter.id.uuidString])
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func rescheduleAll(_ letters: [Letter]) {
        cancelAll()
        for letter in letters {
            schedule(for: letter)
        }
    }
}
