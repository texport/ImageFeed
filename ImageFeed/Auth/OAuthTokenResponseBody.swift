//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 21.03.2024.
//

import UIKit

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String?
    let createdAt: Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
