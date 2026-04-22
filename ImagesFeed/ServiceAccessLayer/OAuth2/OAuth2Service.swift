// MARK: - OAuth2Service.swift
import Foundation

protocol OAuth2ServiceProtocol {
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void)
}

final class OAuth2Service: OAuth2ServiceProtocol {

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }


        let newTask = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }

            // игнорируем completion отменённого запроса
            if let urlError = self.extractURLError(result), urlError.code == .cancelled {
                return
            }

            self.task = nil
            self.lastCode = nil

            switch result {
            case .success(let tokenResponse):
                completion(.success(tokenResponse.accessToken))

            case .failure(let error):
                print("[OAuth2Service.fetchOAuthToken]: NetworkError - \(error), code: \(code)")
                completion(.failure(error))
            }
        }

        self.task = newTask
        newTask.resume()
    }

    private func extractURLError(_ result: Result<OAuthTokenResponseBody, Error>) -> URLError? {
        if case .failure(let error) = result {
            return error as? URLError
        }
        return nil
    }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {

        guard var urlComponents = URLComponents(string: UnsplashConst.baseURL) else {
            print("[OAuth2Service.makeOAuthTokenRequest]: invalidRequest - code: \(code)")
            return nil
        }
        urlComponents.path = "/oauth/token"
        
        let bodyParams = [
            "client_id": UnsplashConst.accessKey,
            "client_secret": UnsplashConst.secretKey,
            "redirect_uri": UnsplashConst.redirectURI,
            "code": code,
            "grant_type": "authorization_code"]
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .data(using: .utf8)

        guard let url = urlComponents.url else {
            print("Failed to create URL from components")
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.httpBody = bodyParams

        return request
    }
}

enum AuthServiceError: Error {
    case invalidRequest
}
