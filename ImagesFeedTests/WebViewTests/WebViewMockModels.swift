import Foundation
@testable import ImagesFeed

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    weak var view: WebViewControllerProtocol?
    
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {}
    
    func code(from url: URL) -> String? {
        return nil
    }
}

final class WebViewControllerSpy: WebViewControllerProtocol {
    var presenter: (any ImagesFeed.WebViewPresenterProtocol)?
    
    var loadFuncDidCalled = false
    
    func load(request: URLRequest) {
        loadFuncDidCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
    }
    
    func setProgressHidden(_ isHidden: Bool) {
    }
    
    
}
