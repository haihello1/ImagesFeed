import Foundation


extension Notification.Name {
    static let profileImageChanged = Notification.Name("profileImageChanged")
    
    /// Triggers logout flow and clears all user data
    static let logoutNeeded = Notification.Name("logoutNeeded")
    
    /// Posted after logout to update UI (e.g., switch root screen)
    static let didLogout = Notification.Name("didLogout")
}
