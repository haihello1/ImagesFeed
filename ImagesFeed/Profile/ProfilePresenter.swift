import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func userDidLogout()
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    weak var view: ProfileViewControllerProtocol?
    private var profileService: ProfileServiceProtocol
    private var profileImageService: ProfileImageServiceProtocol
    
    init(profileService: ProfileServiceProtocol,
         profileImageService: ProfileImageServiceProtocol
    ) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func viewDidLoad() {
        view?.addGradients()
        loadProfile()
    }
    
    private func loadProfile() {
        profileService.fetchProfile { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                self.view?.setProfileDetails(profile: profile)
                self.view?.removeTextGradients()
                
                self.loadImage(username: profile.username)
            case .failure:
                self.view?.showErrorAlert(message: "Не удалось загрузить профиль")
            }
        }
    }
    
    func loadImage(username: String) {
        profileImageService.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let profileImgString):
                guard let url = URL(string: profileImgString) else { return }
                self.view?.setAvatar(url: url)
                self.view?.removeAvatarGradient()
                //
                // Вопрос по поводу removeAvatarGradient(). Передо мной встал выбор - добавить ее в completion у KF в viewcontroller, чтобы градиент убирался ровно после завершения загрузки или оставить в таком виде для тестируемости. Что выбрать? 
                //
            case .failure:
                self.view?.showErrorAlert(message: "Не удалось загрузить фото профиля")
            }
        }
    }
    
    func userDidLogout() {
        NotificationCenter.default.post(name: .logoutNeeded, object: nil)
    }
}


