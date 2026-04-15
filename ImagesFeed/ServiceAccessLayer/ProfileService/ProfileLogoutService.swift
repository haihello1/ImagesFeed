import Foundation
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
        
    private init() { }

    func logout() {
        cleanCookies()
        clearToken()
        clearServicesData()
    }

    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
    }

    private func clearToken() {
        OAuth2TokenStorage.shared.token = nil
    }

    private func clearServicesData() {
        // Очищаем данные профиля, аватарку и список картинок
        // Важно: в самих сервисах эти свойства должны быть доступны для изменения (не private set)
        // Либо добавь в них методы для очистки
        ProfileService.shared.clear()
        ProfileImageService.shared.clear()
        ImagesListService().clear()
    }
}
