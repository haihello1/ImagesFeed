import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    // MARK: - UI Elements
    private let profileImageView = UIImageView()
    private let logoutButton = UIButton()
    private let nameSurname = UILabel()
    private let username = UILabel()
    private let profileMessage = UILabel()

    private var profileImageServiceObserver: NSObjectProtocol?
    
    private var animationLayers = Set<CALayer>()

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateProfileDetails()
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
                self.removeGradients()
            }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if ProfileImageService.shared.avatarURL != nil {
            updateAvatar()
        } else {
            addGradients()
        }
    }
    
    // MARK: - Gradient
    
    private func addGradient(to layer: CALayer, size: CGSize, cornerRadius: CGFloat = 0) {
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(origin: .zero, size: size)
        gradient.locations = [0, 0.1, 0.3]
        gradient.colors = [
            UIColor(red: 0.682, green: 0.686, blue: 0.706, alpha: 1).cgColor,
            UIColor(red: 0.531, green: 0.533, blue: 0.553, alpha: 1).cgColor,
            UIColor(red: 0.431, green: 0.433, blue: 0.453, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        gradient.cornerRadius = cornerRadius
        gradient.masksToBounds = true
        
        layer.addSublayer(gradient)
        animationLayers.insert(gradient)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [0, 0.1, 0.3]
        animation.toValue = [0, 0.8, 1]
        animation.duration = 1.0
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: "locationsChange")
    }
    
    private func addGradients() {
        guard animationLayers.isEmpty else { return }
        
        let avatarSize = AppLayout.avatarSize
        addGradient(
            to: profileImageView.layer,
            size: CGSize(width: avatarSize, height: avatarSize),
            cornerRadius: avatarSize / 2
        )
        
        for label in [nameSurname, username, profileMessage] {
            let size = CGSize(
                width: label.bounds.width > 0 ? label.bounds.width : 200,
                height: label.bounds.height > 0 ? label.bounds.height : 20
            )
            addGradient(to: label.layer, size: size, cornerRadius: 8)
        }
    }
    
    private func removeGradients() {
        animationLayers.forEach { $0.removeFromSuperlayer() }
        animationLayers.removeAll()
    }
    
    // MARK: - Avatar
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            print("[ProfileViewController.updateAvatar]: invalidURL")
            return
        }

        profileImageView.kf.indicatorType = .activity

        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .avatar)
        )
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = AppColors.background
        setupSubviews()
        setupConstraints()
        configureViews()
        configureLogoutButton()
    }

    private func configureLogoutButton() {
        logoutButton.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
    }

    @objc private func logoutButtonPressed() {
        let alert = UIAlertController(
            title: "Пока-пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert
        )
        
        let yesAction = UIAlertAction(title: "Да", style: .default) { [weak self] _ in
            self?.performLogout()
        }
        
        let noAction = UIAlertAction(title: "Нет", style: .cancel)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true)
    }

    private func performLogout() {
        ProfileLogoutService.shared.logout()
        
        guard let window = UIApplication.shared.windows.first else { return }
        
        let splashViewController = SplashViewController()
        
        window.rootViewController = splashViewController
    }

    private func setupSubviews() {
        [profileImageView, logoutButton, nameSurname, username, profileMessage].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppLayout.spacingHorizontal),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: AppLayout.profileTopSpacing),
            profileImageView.heightAnchor.constraint(equalToConstant: AppLayout.avatarSize),
            profileImageView.widthAnchor.constraint(equalToConstant: AppLayout.avatarSize),

            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppLayout.spacingHorizontal),
            logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            logoutButton.heightAnchor.constraint(equalToConstant: AppLayout.logoutImageSize),
            logoutButton.widthAnchor.constraint(equalToConstant: AppLayout.logoutImageSize),

            nameSurname.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            nameSurname.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: AppLayout.spacingBetweenLines),
            nameSurname.trailingAnchor.constraint(lessThanOrEqualTo: logoutButton.leadingAnchor, constant: -20),

            username.leadingAnchor.constraint(equalTo: nameSurname.leadingAnchor),
            username.topAnchor.constraint(equalTo: nameSurname.bottomAnchor, constant: AppLayout.spacingBetweenLines),
            username.trailingAnchor.constraint(lessThanOrEqualTo: logoutButton.trailingAnchor, constant: 20),

            profileMessage.leadingAnchor.constraint(equalTo: nameSurname.leadingAnchor),
            profileMessage.topAnchor.constraint(equalTo: username.bottomAnchor, constant: AppLayout.spacingBetweenLines),
            profileMessage.trailingAnchor.constraint(lessThanOrEqualTo: logoutButton.trailingAnchor, constant: 20),
        ])
    }

    private func configureViews() {
        profileImageView.image = UIImage(resource: .avatar)
        profileImageView.layer.cornerRadius = AppLayout.avatarSize / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        logoutButton.setImage(UIImage(resource: .logoutButton), for: .normal)

        nameSurname.font = AppFonts.title
        nameSurname.textColor = AppColors.textPrimary

        username.font = AppFonts.caption
        username.textColor = AppColors.textSecondary

        profileMessage.font = AppFonts.body
        profileMessage.textColor = AppColors.textPrimary
    }

    // MARK: - Profile Display
    
    private func updateProfileDetails() {
        guard let profile = ProfileService.shared.profile else {
            print("[ProfileViewController.updateProfileDetails]: profile not loaded")
            return
        }

        nameSurname.text = profile.name
        username.text = profile.loginName
        profileMessage.text = profile.bio
    }
}
