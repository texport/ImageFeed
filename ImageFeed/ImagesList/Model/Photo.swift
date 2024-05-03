//
//  Photo.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 02.05.2024.
//

import UIKit

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
}
