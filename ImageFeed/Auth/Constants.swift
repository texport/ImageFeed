//
//  Constants.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 11.03.2024.
//

import UIKit

enum Constants {
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let tokenURLString = "https://unsplash.com/oauth/token"
    static let accessKey = "6mNqBHD7PJHRAIM0RtxpM9_lpFawbzN_I01WdIZA7u0"
    static let secretKey = "aspTBmOO_-TsUQsR9R3elalxMZG3KEyG0ObRVnaCEcI"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_user+read_photos+write_photos+write_likes+write_followers+read_collections+write_collections"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }

    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 authURLString: Constants.unsplashAuthorizeURLString,
                                 defaultBaseURL: Constants.defaultBaseURL)
    }
}
