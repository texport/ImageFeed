//
//  WebViewViewControllerDelegate.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 12.03.2024.
//

import UIKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
