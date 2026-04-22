import UIKit

final class SplashViewController: UIViewController {
    // Руки потянулись переделать часть проекта под DI. Правильно ли сделал? Не слишком ли много зависимостей тяну вниз по ирерархии? Знаю, что splash нужно разделить, но т.к проект расти не будет - оставлю перегруженным. Может быть есть советы по литературе, которую можно почитать для понимания, когда какую архитектуру лучше использовать?
    private let tokenStorage: OAuth2TokenStorageProtocol
    private let logoutService: LogoutService
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    private let imagesListService: ImagesListServiceProtocol
    private let authService: OAuth2ServiceProtocol
    
    init(tokenStorage: OAuth2TokenStorageProtocol,
         logoutService: LogoutService,
         profileService: ProfileServiceProtocol,
         profileImageService: ProfileImageServiceProtocol,
         imagesListService: ImagesListServiceProtocol,
         authService: OAuth2ServiceProtocol
    ) {
        self.tokenStorage = tokenStorage
        self.logoutService = logoutService
        self.profileService = profileService
        self.profileImageService = profileImageService
        self.imagesListService = imagesListService
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    private var isFirstAppearance = true // Добавили флаг
    
    // MARK: - UI
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .unsplashLogo)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background

        view.addSubview(logoImageView)
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 75),
            logoImageView.heightAnchor.constraint(equalToConstant: 75)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard isFirstAppearance else { return }
        isFirstAppearance = false
        
        if tokenStorage.token != nil {
            switchToTabBarController()
        } else {
            showAuthViewController()
        }
    }

    // MARK: - Navigation
    
    private func showAuthViewController() {
        let authVC = AuthViewController(tokenStorage: tokenStorage, authService: authService)
        authVC.delegate = self

        let navigationController = UINavigationController(rootViewController: authVC)
        navigationController.modalPresentationStyle = .fullScreen

        present(navigationController, animated: true)
    }

    func switchToTabBarController() {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first(where: { $0.isKeyWindow })
        else {
            assertionFailure("No keyWindow found")
            return
        }

        let tabBarController = createTabBarController()

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = tabBarController
            }
        )
    }
    
    // MARK: - TabBar Creation
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        configureTabBarAppearance(for: tabBarController)

        let feedPresenter = ImageFeedPresenter(imagesListService: imagesListService)
        let profilePresenter = ProfilePresenter(profileService: profileService, profileImageService: profileImageService)
        let firstVC = ImageFeedViewController(presenter: feedPresenter)
        firstVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "rectangle.stack.fill"),
            tag: 0
        )

        let secondVC = ProfileViewController(presenter: profilePresenter)
        
        secondVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "person.circle.fill"),
            tag: 1
        )

        tabBarController.viewControllers = [firstVC, secondVC]
        return tabBarController
    }

    private func configureTabBarAppearance(for tabBarController: UITabBarController) {
        let tabBar = tabBarController.tabBar

        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = AppColors.background
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.shadowColor = nil

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - AuthViewControllerDelegate

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        switchToTabBarController()
    }
}
