//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 21.03.2024.
//

import UIKit
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage() // Singleton instance
    private let tokenKey = "oauthTokenKey"

    private init() {}  // Private initializer to ensure singleton usage

    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let newValue = newValue {
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
