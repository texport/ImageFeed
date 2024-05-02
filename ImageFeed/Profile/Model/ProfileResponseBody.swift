//
//  ProfileResponseBody.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 28.04.2024.
//

import UIKit

struct ProfileResponseBody: Codable {
    let id: String
    let username: String
    let name: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    let email: String?
    let location: String?
}
