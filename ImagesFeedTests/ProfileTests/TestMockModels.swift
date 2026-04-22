import XCTest
@testable import ImagesFeed

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: any ImagesFeed.ProfilePresenterProtocol
    
    init(presenter: any ImagesFeed.ProfilePresenterProtocol) {
        self.presenter = presenter
    }
    
    func addGradients() {
    }
    
    func removeAvatarGradient() {
    }
    
    func removeTextGradients() {
    }
    
    func setProfileDetails(profile: ImagesFeed.Profile) {
    }
    
    func setAvatar(url: URL) {
    }
    
    func showErrorAlert(message: String) {
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    
    var view: (any ImagesFeed.ProfileViewControllerProtocol)?
    
    var viewDidLoadCalled = false
    
    func userDidLogout() {
    }
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}

class ProfileServiceDummy: ProfileServiceProtocol {
    func fetchProfile(completion: @escaping (Result<ImagesFeed.Profile, any Error>) -> Void) {}
    
    func clear() {}
}

class ProfileImageServiceDummy: ProfileImageServiceProtocol {
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, any Error>) -> Void) {}
    
    func clear() {}
}

final class MockView: ProfileViewControllerProtocol {
    var presenter: any ImagesFeed.ProfilePresenterProtocol
    
    init(presenter: any ImagesFeed.ProfilePresenterProtocol) {
        self.presenter = presenter
    }
    // 1st test variables
    var receivedProfile: Profile?
    var addGradientCalled = false
    var setAvatarCalled = false
    var removeGradientCalled = false
    
    // 2nd test variables
    var showErrorAlertCalled = false
    
    private var _profileGradientRemoved = false
    func addGradients() {
        addGradientCalled = true
    }
    
    func removeAvatarGradient() {
        if _profileGradientRemoved == true {
            removeGradientCalled = true
        }
    }
    
    func removeTextGradients() {
        _profileGradientRemoved = true
    }
    
    func setAvatar(url: URL) {
        setAvatarCalled = true
    }
    
    func showErrorAlert(message: String) {
        showErrorAlertCalled = true
    }
    
    func setProfileDetails(profile: Profile) {
        receivedProfile = profile
    }
}


final class MockProfileService: ProfileServiceProtocol {
    func clear() {}
    
    var result: Result<Profile, Error>?
    
    func fetchProfile(completion: @escaping (Result<Profile, Error>) -> Void) {
        if let result {
            completion(result)
        } else {
            completion(.failure(TestError.loadError))
        }
    }
}

final class MockProfileImageService: ProfileImageServiceProtocol {
    func clear() {}
    
    var result: Result<String, Error>?

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        if let result {
            completion(result)
        } else {
            completion(.failure(TestError.loadError))
        }
    }
}

enum TestError: Error {
    case loadError
}
