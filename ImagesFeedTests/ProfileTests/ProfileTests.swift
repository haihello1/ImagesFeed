import XCTest
@testable import ImagesFeed


final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsPresenterViewDidLoad() {

        let profilePreseter = ProfilePresenterSpy()
        let profileViewController = ProfileViewController(presenter: profilePreseter)
        
        profileViewController.presenter = profilePreseter
        profilePreseter.view = profileViewController
        
        _ = profileViewController.view
        
        XCTAssertTrue(profilePreseter.viewDidLoadCalled)
    }
    
    func test_profileLoadsWithCorrectData() {
        // Arrange
        let mockProfileService = MockProfileService()
        let mockImageService = MockProfileImageService()
        
        let expectedProfile = Profile(
            username: "john_doe",
            name: "John Doe",
            loginName: "@john_doe",
            bio: "iOS Developer"
        )
        mockProfileService.result = .success(expectedProfile)
        mockImageService.result = .success(expectedProfile.username)

        
        let profilePresenter = ProfilePresenter(
            profileService: mockProfileService,
            profileImageService: mockImageService
        )
        let mockView = MockView(presenter: profilePresenter)

        
        profilePresenter.view = mockView
        
        // Act
        profilePresenter.viewDidLoad()
        
        // Assert
        XCTAssertEqual(mockView.receivedProfile?.name, expectedProfile.name)
        XCTAssertEqual(mockView.receivedProfile?.loginName, expectedProfile.loginName)
        XCTAssertEqual(mockView.receivedProfile?.bio, expectedProfile.bio)
        
        XCTAssertTrue(mockView.setAvatarCalled)
        XCTAssertTrue(mockView.addGradientCalled)
        XCTAssertTrue(mockView.removeGradientCalled)
    }
    
    func test_presenterShowsAlertGettingError() {
        // Arrange
        let mockProfileService = MockProfileService()
        let mockImageService = MockProfileImageService()
        
        let profilePresenter = ProfilePresenter(
            profileService: mockProfileService,
            profileImageService: mockImageService
        )
        let mockView = MockView(presenter: profilePresenter)

        profilePresenter.view = mockView
        
        // Act
        profilePresenter.viewDidLoad()
        
        // Assert
        XCTAssertTrue(mockView.showErrorAlertCalled)
    }
}
