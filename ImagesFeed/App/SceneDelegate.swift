import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let tabBarController = UITabBarController()
        
        configureTabBarAppearance(for: tabBarController)
        
        let firstVC = ImageFeedViewController()
        firstVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "rectangle.stack.fill"), tag: 0)

        let secondVC = ProfileViewController()
        secondVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person.circle.fill"), tag: 1)

        tabBarController.viewControllers = [firstVC, secondVC]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
    
    private func configureTabBarAppearance(for tabBarController: UITabBarController) {
        let tabBar = tabBarController.tabBar
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.backgroundColor = UIColor(hex: "#1A1B22")
        
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.systemGray
        ]
        
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        
        appearance.shadowColor = nil
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
