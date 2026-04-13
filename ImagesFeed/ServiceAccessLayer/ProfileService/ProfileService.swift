import Foundation

final class ProfileService: ProfileServiceProtocol {

    // MARK: - Singleton
    static let shared = ProfileService()
    private init() {}

    // MARK: - Properties
    private(set) var profile: Profile?
        private let urlSession = URLSession.shared
        private var task: URLSessionTask? // Добавили таск

    // MARK: - Public
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService.makeProfileRequest]: invalidRequest")
            completion(.failure(ProfileRequestError.invalidRequest))
            return
        }

        let newTask = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            self.task = nil // Очищаем таск после завершения

            switch result {
            case .success(let profileResult):
                let profile = Profile(
                    username: profileResult.username ?? "",
                    name: profileResult.fullName,
                    loginName: "@\(profileResult.username ?? "")",
                    bio: profileResult.bio ?? ""
                )

                self.profile = profile

                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in }

                completion(.success(profile))

            case .failure(let error):
                // Игнорируем ошибку отмены запроса
                if (error as? URLError)?.code == .cancelled { return }
                print("[ProfileService.fetchProfile]: NetworkError - \(error)")
                completion(.failure(error))
            }
        }

        self.task = newTask
        newTask.resume()
    }
    
    // MARK: - Private
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard var urlComponents = URLComponents(url: UnsplashConst.defaultApiURL, resolvingAgainstBaseURL: false) else {
            return nil
        }

        urlComponents.path = "/me"

        guard let url = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}


// MARK: - Protocol

protocol ProfileServiceProtocol {
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void)
}

// MARK: - Errors

enum ProfileRequestError: Error {
    case invalidRequest
    case invalidResponse
}
