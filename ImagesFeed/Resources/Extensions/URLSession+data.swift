// MARK: - URLSession+Extensions.swift
import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case invalidResponse
    case noData
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ [URLSession] Network error: \(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                return
            }
            
            guard let data = data, let response = response else {
                print("❌ [URLSession] No data or response")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                print("❌ [URLSession] Invalid response type")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.invalidResponse))
                return
            }
            
            if 200..<300 ~= statusCode {
                fulfillCompletionOnTheMainThread(.success(data))
            } else {
                print("❌ [URLSession] HTTP error with status code: \(statusCode)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
            }
        }
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let task = data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try decoder.decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    print("❌ [objectTask] Decoding error: \(error.localizedDescription), Data: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
        return task
    }
}
