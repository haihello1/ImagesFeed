import XCTest
@testable import ImagesFeed

// MARK: - Tests

final class WebViewViewControllerTests: XCTestCase {
    
    func testViewControllerCallsPresenterViewDidLoad() {
        let viewController = WebViewController()
        
        let presenterSpy = WebViewPresenterSpy()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenterSpy.viewDidLoadCalled, "Ожидалось, что presenter.viewDidLoad() будет вызван")
    }
    
    func testPresenterCallsLoadRequest() {
        let webViewPresenter = WebViewPresenter(authHelper: AuthHelper())
        let webViewController = WebViewControllerSpy()
        webViewPresenter.view = webViewController
        webViewController.presenter = webViewPresenter
        
        webViewPresenter.viewDidLoad()
        XCTAssertTrue(webViewController.loadFuncDidCalled, "Expected WebViewController.load() to be called")
    }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        let progress: Float = 1
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() throws {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()
        let urlString = try XCTUnwrap(url?.absoluteString)
        
        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCorrectCodeFromURL() {
        let authHelper = AuthHelper()
        let baseApiURL = AuthConfiguration.standard.baseApiUrlString
        let codeToCheck = "123"

        let stringURL = "\(baseApiURL)/oauth/authorize/native?code=\(codeToCheck)"
        let url = URL(string: stringURL)!
        
        let code = authHelper.code(from: url)

        XCTAssertEqual(code, codeToCheck)
    }
    
    func testIncorrectCodeFromURL() {
        let authHelper = AuthHelper()
        let baseApiURL = AuthConfiguration.standard.baseApiUrlString
        let codeToCheck = "123"
        
        let stringURL = "\(baseApiURL)/music_by_code?code=\(codeToCheck)"
        let url = URL(string: stringURL)!
        
        let code = authHelper.code(from: url)

        XCTAssertNil(code)
    }
}
