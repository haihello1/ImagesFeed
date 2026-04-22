import Foundation


protocol ImageFeedPresenterProtocol {
    var view: ImageFeedViewControllerProtocol? { get set }
    var photosCount: Int { get }
    func photo(at index: Int) -> Photo

    func viewDidLoad()
    func fetchNextPageIfNeeded(forRowAt index: Int)
    func didSelectRow(at index: Int)
    func didTapLike(at index: Int)
}


final class ImageFeedPresenter: ImageFeedPresenterProtocol {
    weak var view: ImageFeedViewControllerProtocol?

    private let imagesListService: ImagesListServiceProtocol
    private var imagesListServiceObserver: NSObjectProtocol?
    private var photos: [Photo] = []

    init(imagesListService: ImagesListServiceProtocol) {
        self.imagesListService = imagesListService
    }

    var photosCount: Int {
        return photos.count
    }

    func photo(at index: Int) -> Photo {
        return photos[index]
    }

    func viewDidLoad() {
        setupObserver()
        imagesListService.fetchPhotosNextPage()
    }

    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        guard oldCount != newCount else { return }

        photos = imagesListService.photos

        // Передаём диапазон индексов — View сам строит IndexPath
        view?.insertRows(from: oldCount, to: newCount)
    }

    func fetchNextPageIfNeeded(forRowAt index: Int) {
        if index == photos.count - 1 {
            imagesListService.fetchPhotosNextPage()
        }
    }

    func didSelectRow(at index: Int) {
        let photo = photos[index]
        guard let url = URL(string: photo.largeImageURL) else { return }
        view?.presentSingleImage(url: url)
    }

    func didTapLike(at index: Int) {
        let photo = photos[index]
        view?.showLoading()

        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
            guard let self else { return }
            self.view?.hideLoading()

            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                // Передаём чистый индекс — View сам строит IndexPath
                self.view?.updateCellLikeState(at: index, isLiked: self.photos[index].isLiked)
            case .failure:
                self.view?.showErrorAlert()
            }
        }
    }
}
