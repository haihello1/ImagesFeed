import UIKit

final class ProfileImageService {
    
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name("ProfileImageProviderDidChange")
    
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {

        task?.cancel()
        
        guard let token = OAuth2TokenStorage().token else {
            print("[ProfileImageService.fetchProfileImageURL]: invalidRequest - no token")
            completion(.failure(ProfileRequestError.invalidRequest))
            return
        }

        guard let request = makeProfileImageRequest(username: username, token: token) else {
            print("Failed to create request")
            completion(.failure(ProfileRequestError.invalidRequest))
            return
        }

        let newTask = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }

            self.task = nil
            switch result {
            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small
                
                self.avatarURL = profileImageURL
                completion(.success(profileImageURL))
                
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )
                
            case .failure(let error):

                guard (error as NSError).code != NSURLErrorCancelled else { return }
                print("[ProfileImageService.fetchProfileImageURL]: NetworkError - \(error), username: \(username)")
                completion(.failure(error))
            }
        }
        
        task = newTask
        task?.resume()
    }
    
    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {
        guard var components = URLComponents(url: UnsplashConst.defaultApiURL, resolvingAgainstBaseURL: false) else {
            print("[ProfileImageService.makeProfileImageRequest]: invalidRequest - username: \(username)")
            return nil
        }
        components.path = "/users/\(username)"
        
        guard let url = components.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}
