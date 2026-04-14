// MARK: - OAuth2TokenStorage.swift
import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage: OAuth2TokenStorageProtocol {
    private let tokenKey = "BearerToken"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let value = newValue {
                KeychainWrapper.standard.set(value, forKey: tokenKey)
                print("Token saved")
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
                print("Token removed")
            }
        }
    }
}

protocol OAuth2TokenStorageProtocol {
    var token: String? { get set }
}
