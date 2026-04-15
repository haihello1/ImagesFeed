import Foundation

final class ImagesListService {
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastLoadedPage: Int?
    

    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")
    private(set) var photos: [Photo] = []
    
    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)
        guard task == nil else { return }
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        guard let request = makePhotosRequest(page: nextPage) else { return }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            self.task = nil
            
            switch result {
            case .success(let results):
                let newPhotos = results.map { res in
                    let iso8601Formatter = ISO8601DateFormatter()
                    let createdAtString = res.createdAt.map {
                        iso8601Formatter.string(from: $0)
                    }
                    
                    return Photo(
                        id: res.id,
                        size: CGSize(width: res.width, height: res.height),
                        createdAt: createdAtString,
                        welcomeDescription: res.description,
                        thumbImageURL: res.urls.thumb,
                        largeImageURL: res.urls.full,
                        isLiked: res.likedByUser
                    )
                }
                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage
                NotificationCenter.default.post(name: Self.didChangeNotification, object: self)
            case .failure(let error):
                print("[ImagesListService]: Fetch error - \(error)")
            }
        }
        task?.resume()
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard let request = makeLikeRequest(photoId: photoId, isLike: isLike) else { return }
        
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.updatePhotoLike(photoId: photoId)
                completion(.success(()))
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    private func updatePhotoLike(photoId: String) {
        if let index = photos.firstIndex(where: { $0.id == photoId }) {
            let photo = photos[index]

            let newPhoto = Photo(
                id: photo.id,
                size: photo.size,
                createdAt: photo.createdAt,
                welcomeDescription: photo.welcomeDescription,
                thumbImageURL: photo.thumbImageURL,
                largeImageURL: photo.largeImageURL,
                isLiked: !photo.isLiked
            )
            photos[index] = newPhoto
        }
    }
    
    private func makePhotosRequest(page: Int) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        var components = URLComponents(url: UnsplashConst.defaultApiURL, resolvingAgainstBaseURL: false)
        components?.path = "/photos"
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "10")
        ]
        var request = URLRequest(url: components!.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func makeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else { return nil }
        var components = URLComponents(url: UnsplashConst.defaultApiURL, resolvingAgainstBaseURL: false)
        components?.path = "/photos/\(photoId)/like"
        var request = URLRequest(url: components!.url!)
        request.httpMethod = isLike ? HTTPMethod.post.rawValue : HTTPMethod.delete.rawValue
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func clear() {
        photos = []
        task?.cancel()
        task = nil
    }
}
