import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    // MARK: - UI Elements
    lazy private var profileImageView = UIImageView()
    lazy private var logoutButton = UIButton()
    lazy private var nameSurname = UILabel()
    lazy private var username = UILabel()
    lazy private var profileMessage = UILabel()

    private var profileImageServiceObserver: NSObjectProtocol?

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
        profileImageServiceObserver = NotificationCenter.default    // 2
            .addObserver(
                forName: ProfileImageService.didChangeNotification, // 3
                object: nil,                                        // 4
                queue: .main                                        // 5
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()                                 // 6
            }
        updateAvatar()
    }
    
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
        OAuth2TokenStorage().token = nil
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
