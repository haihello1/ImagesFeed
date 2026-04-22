import XCTest
@testable import ImagesFeed

// MARK: - Tests

final class ImageFeedPresenterTests: XCTestCase {

    func test_viewDidLoad_callsFetchPhotosNextPage() {
        // Arrange
        let mockService = MockImagesListService()
        let presenter = ImageFeedPresenter(imagesListService: mockService)
        let mockView = MockImageFeedView(presenter: presenter)
        presenter.view = mockView

        // Act
        presenter.viewDidLoad()

        // Assert
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled)
    }

    func test_photosCount_returnsZeroInitially() {
        // Arrange
        let mockService = MockImagesListService()
        let presenter = ImageFeedPresenter(imagesListService: mockService)

        // Assert
        XCTAssertEqual(presenter.photosCount, 0)
    }

    func test_updateTableViewAnimated_insertsRowsWhenPhotosLoaded() {
        // Arrange
        let mockService = MockImagesListService()
        let presenter = ImageFeedPresenter(imagesListService: mockService)
        let mockView = MockImageFeedView(presenter: presenter)
        presenter.view = mockView

        let newPhotos = [
            Photo.make(id: "1"),
            Photo.make(id: "2"),
            Photo.make(id: "3")
        ]
        mockService.photos = newPhotos

        // Act
        presenter.viewDidLoad()
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)

        // Assert
        XCTAssertTrue(mockView.insertRowsCalled)
        XCTAssertEqual(mockView.insertRowsOldCount, 0)
        XCTAssertEqual(mockView.insertRowsNewCount, 3)
    }

    func test_fetchNextPageIfNeeded_fetchesWhenAtLastIndex() {
        // Arrange
        let mockService = MockImagesListService()
        mockService.photos = [Photo.make(id: "1"), Photo.make(id: "2")]

        let presenter = ImageFeedPresenter(imagesListService: mockService)
        let mockView = MockImageFeedView(presenter: presenter)
        presenter.view = mockView

        presenter.viewDidLoad()
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)

        mockService.fetchPhotosNextPageCalled = false

        // Act
        presenter.fetchNextPageIfNeeded(forRowAt: 1)

        // Assert
        XCTAssertTrue(mockService.fetchPhotosNextPageCalled)
    }

    func test_fetchNextPageIfNeeded_doesNotFetchWhenNotAtLastIndex() {
        // Arrange
        let mockService = MockImagesListService()
        mockService.photos = [Photo.make(id: "1"), Photo.make(id: "2"), Photo.make(id: "3")]

        let presenter = ImageFeedPresenter(imagesListService: mockService)
        let mockView = MockImageFeedView(presenter: presenter)
        presenter.view = mockView

        presenter.viewDidLoad()
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)

        mockService.fetchPhotosNextPageCalled = false

        // Act
        presenter.fetchNextPageIfNeeded(forRowAt: 1)

        // Assert
        XCTAssertFalse(mockService.fetchPhotosNextPageCalled)
    }

    func test_didSelectRow_presentsSingleImageWithCorrectURL() {
        // Arrange
        let mockService = MockImagesListService()
        let largeURL = "https://example.com/large.jpg"
        mockService.photos = [Photo.make(id: "1", largeImageURL: largeURL)]

        let presenter = ImageFeedPresenter(imagesListService: mockService)
        let mockView = MockImageFeedView(presenter: presenter)
        presenter.view = mockView

        presenter.viewDidLoad()
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)

        // Act
        presenter.didSelectRow(at: 0)

        // Assert
        XCTAssertTrue(mockView.presentSingleImageCalled)
        XCTAssertEqual(mockView.presentedImageURL?.absoluteString, largeURL)
    }

    func test_didTapLike_onSuccess_updatesLikeState() {
        // Arrange
        let mockService = MockImagesListService()
        mockService.photos = [Photo.make(id: "photo1", isLiked: false)]
        mockService.changeLikeResult = .success(())

        let presenter = ImageFeedPresenter(imagesListService: mockService)
        let mockView = MockImageFeedView(presenter: presenter)
        presenter.view = mockView

        presenter.viewDidLoad()
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)

        // Act
        presenter.didTapLike(at: 0)

        // Assert
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.updateCellLikeStateCalled)
    }

    func test_didTapLike_onFailure_showsErrorAlert() {
        // Arrange
        let mockService = MockImagesListService()
        mockService.photos = [Photo.make(id: "photo1", isLiked: false)]
        mockService.changeLikeResult = .failure(TestError.loadError)

        let presenter = ImageFeedPresenter(imagesListService: mockService)
        let mockView = MockImageFeedView(presenter: presenter)
        presenter.view = mockView

        presenter.viewDidLoad()
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)

        // Act
        presenter.didTapLike(at: 0)

        // Assert
        XCTAssertTrue(mockView.showLoadingCalled)
        XCTAssertTrue(mockView.hideLoadingCalled)
        XCTAssertTrue(mockView.showErrorAlertCalled)
        XCTAssertFalse(mockView.updateCellLikeStateCalled)
    }
}

