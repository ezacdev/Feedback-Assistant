import UserNotifications

final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {

    weak var dataController: DataController?

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard
            let id = response.notification.request.content.userInfo["issueID"]
                as? String
        else {
            return
        }

        await MainActor.run {
            dataController?.loadIssueFromExternalTrigger(id)
        }
    }
}
