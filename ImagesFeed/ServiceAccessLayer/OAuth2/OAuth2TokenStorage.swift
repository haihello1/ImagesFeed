// MARK: - OAuth2TokenStorage.swift
import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: tokenKey)
            print("Token \(newValue != nil ? "saved" : "removed")")
        }
    }
}
