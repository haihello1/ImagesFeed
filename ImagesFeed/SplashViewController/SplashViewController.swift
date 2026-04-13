import UIKit

final class SplashViewController: UIViewController {

    // MARK: - Properties
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
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
        
        if let token = storage.token {
            fetchProfile(token: token)
        } else {
            showAuthViewController()
        }
    }

    // MARK: - Navigation
    private func showAuthViewController() {
        let authVC = AuthViewController()
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

    // MARK: - Profile Fetching
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }

            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure(let error):
                if (error as? URLError)?.code == .notConnectedToInternet {
                    self.showErrorAlert()
                } else {
                    self.logout()
                }
            }
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось загрузить профиль",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let token = self?.storage.token else { return }
            self?.fetchProfile(token: token)
        })

        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive) { [weak self] _ in
            self?.logout()
        })

        present(alert, animated: true)
    }
    
    private func logout() {
        storage.token = nil
        showAuthViewController()
    }
    
    // MARK: - TabBar Creation
    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        configureTabBarAppearance(for: tabBarController)

        let firstVC = ImageFeedViewController()
        firstVC.tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: "rectangle.stack.fill"),
            tag: 0
        )

        let secondVC = ProfileViewController()
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

        guard let token = storage.token else {
            return
        }

        fetchProfile(token: token)
    }
}
