import UIKit

final class ProfileViewController: UIViewController {
    
    // MARK: - UI Elements
    private let profileImageView = UIImageView()
    private let logoutButton = UIButton()
    private let nameSurname = UILabel()
    private let username = UILabel()
    private let profileMessage = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = AppColors.background
        setupSubviews()
        setupConstraints()
        configureViews()
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
        
        nameSurname.text = "Имя Фамилия"
        nameSurname.font = AppFonts.title
        nameSurname.textColor = AppColors.textPrimary
        
        username.text = "@asd"
        username.font = AppFonts.caption
        username.textColor = AppColors.textSecondary
        
        profileMessage.text = "Hello world!"
        profileMessage.font = AppFonts.body
        profileMessage.textColor = AppColors.textPrimary
    }
    
}
