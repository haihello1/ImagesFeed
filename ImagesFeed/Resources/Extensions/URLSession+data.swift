// MARK: - URLSession+Extensions.swift
import Foundation

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
}
