import Foundation
import WebKit

final class LogoutService {
    
    private var observer: NSObjectProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let imagesListService: ImagesListServiceProtocol
    private let tokenStorage: OAuth2TokenStorageProtocol
    
    init(
        profileService: ProfileServiceProtocol,
        profileImageService: ProfileImageServiceProtocol,
        tokenStorage: OAuth2TokenStorageProtocol,
        imagesListService: ImagesListServiceProtocol
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.imagesListService = imagesListService
        self.tokenStorage = tokenStorage
        
        addObserver()
    }
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func userDidLogout() {
        cleanCookies()
        clearToken()
        clearServicesData()
        NotificationCenter.default.post(name: .didLogout, object: nil)
        // Нормально, что у нас класс слушает и прокидывает дальше уведомления?
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
        tokenStorage.token = nil
    }
    
    private func clearServicesData() {
        profileService.clear()
        profileImageService.clear()
        imagesListService.clear()
    }
    
    private func addObserver() {
        observer = NotificationCenter.default.addObserver(
            forName: .logoutNeeded,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.userDidLogout()
        }
    }
}
