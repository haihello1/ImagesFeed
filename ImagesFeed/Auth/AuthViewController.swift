// MARK: - AuthViewController.swift
import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
    var authService: OAuth2ServiceProtocol
    var tokenStorage: OAuth2TokenStorageProtocol
    
    init(delegate: AuthViewControllerDelegate? = nil,
         tokenStorage: OAuth2TokenStorageProtocol,
         authService: OAuth2ServiceProtocol
    ) {
        self.delegate = delegate
        self.tokenStorage = tokenStorage
        self.authService = authService
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let unsplashLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .unsplashLogo)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("Войти", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        btn.setTitleColor(AppColors.background, for: .normal)
        btn.backgroundColor = AppColors.buttonBackground
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.accessibilityIdentifier = "Authenticate"
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.background
        
        view.addSubview(unsplashLogo)
        view.addSubview(loginButton)
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            unsplashLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            unsplashLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
            unsplashLogo.widthAnchor.constraint(equalToConstant: 60),
            unsplashLogo.heightAnchor.constraint(equalToConstant: 60),
            
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppLayout.spacingHorizontal),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppLayout.spacingHorizontal),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func loginButtonTapped() {
        let webViewPresenter = WebViewPresenter(authHelper: AuthHelper())
        let webViewVC = WebViewController()
        webViewVC.presenter = webViewPresenter
        webViewVC.delegate = self
        webViewPresenter.view = webViewVC
        navigationController?.pushViewController(webViewVC, animated: true)
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    
    func webViewViewControllerDidCancel(_ vc: WebViewController) {
        navigationController?.popViewController(animated: true)
    }
    
    func webViewViewController(_ vc: WebViewController, didAuthenticateWithCode code: String) {
        
        navigationController?.popViewController(animated: true)
        
        UIBlockingProgressHUD.show()
                
        authService.fetchOAuthToken(code) { [weak self] result in

            UIBlockingProgressHUD.dismiss()
            
            guard let self else { return }
            
            switch result {
            case .success(let token):
                tokenStorage.token = token
                self.delegate?.didAuthenticate(self)
                
            case .failure(let error):
                print("[AuthViewController.didAuthenticate]: NetworkError - \(error)")

                let alert = UIAlertController(
                    title: "Что-то пошло не так",
                    message: "Не удалось войти в систему",
                    preferredStyle: .alert
                )

                alert.addAction(UIAlertAction(title: "Ок", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
}
