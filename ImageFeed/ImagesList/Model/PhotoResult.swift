//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 02.05.2024.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let user: User
    let urls: UrlsResult
    let links: PhotoLinks

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case width
        case height
        case color
        case blurHash = "blur_hash"
        case likes
        case likedByUser = "liked_by_user"
        case description
        case user
        case urls
        case links
    }
}

struct UrlsResult: Codable {
    let raw: URL
    let full: URL
    let regular: URL
    let small: URL
    let thumb: URL
}

struct User: Codable {
    let id: String
    let username: String
    let name: String
    let portfolioUrl: URL?
    let bio: String?
    let location: String?
    let totalLikes: Int
    let totalPhotos: Int
    let totalCollections: Int
    let instagramUsername: String?
    let twitterUsername: String?
    let profileImage: ProfileImage
    let links: UserLinks

    enum CodingKeys: String, CodingKey {
        case id
        case username
        case name
        case portfolioUrl = "portfolio_url"
        case bio
        case location
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case instagramUsername = "instagram_username"
        case twitterUsername = "twitter_username"
        case profileImage = "profile_image"
        case links
    }
}

struct ProfileImage: Codable {
    let small: URL
    let medium: URL
    let large: URL
}

struct UserLinks: Codable {
    let selfLink: URL
    let html: URL
    let photos: URL
    let likes: URL
    let portfolio: URL

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case html
        case photos
        case likes
        case portfolio
    }
}

struct PhotoLinks: Codable {
    let selfLink: URL
    let html: URL
    let download: URL
    let downloadLocation: URL

    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case html
        case download
        case downloadLocation = "download_location"
    }
}
