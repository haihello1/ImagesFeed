import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private var logoutService: LogoutService?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        addLogoutObserver()
        
        let splashVC = createSplashVC()
        
        window?.rootViewController = splashVC
        window?.makeKeyAndVisible()
    }
    
    private func addLogoutObserver() {
        NotificationCenter.default.addObserver(
            forName: .didLogout,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.switchToRouter()
            print("получили прослушку на смену экрана")
        }
    }
    
    func createSplashVC() -> SplashViewController {
        let tokenStorage = OAuth2TokenStorage()
        let profileService = ProfileService(tokenStorage: tokenStorage)
        let profileImageService = ProfileImageService(tokenStorage: tokenStorage)
        let imagesListService = ImagesListService(tokenStorage: tokenStorage)
        let authService = OAuth2Service()
        
        let logoutService = LogoutService(
            profileService: profileService,
            profileImageService: profileImageService,
            tokenStorage: tokenStorage,
            imagesListService: imagesListService
        )
        self.logoutService = logoutService
        
        let splashViewController = SplashViewController(
            tokenStorage: tokenStorage,
            logoutService: logoutService,
            profileService: profileService,
            profileImageService: profileImageService,
            imagesListService: imagesListService,
            authService: authService
        )
        
        return splashViewController
    }
    
    private func switchToRouter() {
        let splash = createSplashVC()
        window?.rootViewController = splash
        print("Поменяли экран")
    }
}

