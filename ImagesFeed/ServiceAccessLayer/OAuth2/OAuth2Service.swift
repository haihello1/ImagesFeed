// MARK: - OAuth2Service.swift
import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private let tokenStorage = OAuth2TokenStorage()
    
    private init() {}
    
    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Failed to create request")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        print("Starting token request...")
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let tokenResponse = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    
                    self.tokenStorage.token = tokenResponse.accessToken
                    print("Token received and saved successfully")
                    
                    completion(.success(tokenResponse.accessToken))
                    
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                print("Request failed: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            print("Failed to create base URL")
            return nil
        }
        
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            print("Failed to create URLComponents")
            return nil
        }
        
        urlComponents.path = "/oauth/token"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: UnsplashConst.accessKey),
            URLQueryItem(name: "client_secret", value: UnsplashConst.secretKey),
            URLQueryItem(name: "redirect_uri", value: UnsplashConst.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("Failed to create URL from components")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        print("Request created: \(url.absoluteString)")
        
        return request
    }
}
