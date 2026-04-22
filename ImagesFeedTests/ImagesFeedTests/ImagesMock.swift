import XCTest
@testable import ImagesFeed

final class MockImageFeedView: ImageFeedViewControllerProtocol {
    var presenter: ImageFeedPresenterProtocol

    init(presenter: ImageFeedPresenterProtocol) {
        self.presenter = presenter
    }

    var insertRowsCalled = false
    var insertRowsOldCount: Int = 0
    var insertRowsNewCount: Int = 0

    var showLoadingCalled = false
    var hideLoadingCalled = false
    var showErrorAlertCalled = false

    var updateCellLikeStateCalled = false
    var updatedLikeIndex: Int?
    var updatedLikeState: Bool?

    var presentSingleImageCalled = false
    var presentedImageURL: URL?

    func insertRows(from oldCount: Int, to newCount: Int) {
        insertRowsCalled = true
        insertRowsOldCount = oldCount
        insertRowsNewCount = newCount
    }

    func showLoading() {
        showLoadingCalled = true
    }

    func hideLoading() {
        hideLoadingCalled = true
    }

    func showErrorAlert() {
        showErrorAlertCalled = true
    }

    func updateCellLikeState(at index: Int, isLiked: Bool) {
        updateCellLikeStateCalled = true
        updatedLikeIndex = index
        updatedLikeState = isLiked
    }

    func presentSingleImage(url: URL) {
        presentSingleImageCalled = true
        presentedImageURL = url
    }
}

// MARK: - Helpers

extension Photo {
    static func make(
        id: String,
        largeImageURL: String = "https://example.com/large.jpg",
        isLiked: Bool = false
    ) -> Photo {
        Photo(
            id: id,
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "https://example.com/thumb.jpg",
            largeImageURL: largeImageURL,
            isLiked: isLiked
        )
    }
}


final class MockImagesListService: ImagesListServiceProtocol {
    var photos: [Photo] = []
    var fetchPhotosNextPageCalled = false
    var changeLikeResult: Result<Void, Error> = .success(())

    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }

    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        completion(changeLikeResult)
    }

    func clear() {
        photos = []
    }
}
