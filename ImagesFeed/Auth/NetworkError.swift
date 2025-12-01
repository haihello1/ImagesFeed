// MARK: - NetworkError.swift
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
