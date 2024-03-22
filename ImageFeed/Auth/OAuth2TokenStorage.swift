//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 21.03.2024.
//

import UIKit

class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "oauthTokenKey"

    var token: String? {
        get {
            return userDefaults.string(forKey: tokenKey)
        }
        set {
            userDefaults.set(newValue, forKey: tokenKey)
        }
    }
}
