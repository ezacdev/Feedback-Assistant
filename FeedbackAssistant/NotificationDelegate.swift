import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    weak var dataController: DataController?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // 1) достаём issueID из уведомления
        guard
            let id = response.notification.request.content.userInfo["issueID"]
                as? String
        else {
            return
        }

        // 2) обновляем состояние приложения на главном потоке
        await MainActor.run {
            dataController?.loadIssueFromExternalTrigger(id)
        }
    }
}
