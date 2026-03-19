// MARK: - AuthViewController.swift
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController {
    
    weak var delegate: AuthViewControllerDelegate?
    
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
        let webViewVC = WebViewViewController()
        webViewVC.delegate = self
        navigationController?.pushViewController(webViewVC, animated: true)
    }
}
