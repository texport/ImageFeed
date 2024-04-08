//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 22.03.2024.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        decideNextViewController()
    }
    
    private func decideNextViewController() {
        if OAuth2TokenStorage().token != nil {
            presentGallery()
        } else {
            presentAuth()
        }
    }
    
    func didAuthenticate() {
        presentGallery()
    }
    
    private func presentGallery() {
        if let tabBarController = storyboard?.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            tabBarController.modalPresentationStyle = .fullScreen // Задаем стиль презентации
            present(tabBarController, animated: false, completion: nil)
        }
    }
    
    private func presentAuth() {
        if let authNavigationController = storyboard?.instantiateViewController(withIdentifier: "AuthNavigationController") as? UINavigationController,
           let authViewController = authNavigationController.viewControllers.first as? AuthViewController {
            authViewController.delegate = self  // Устанавливаем SplashViewController в качестве делегата
            authNavigationController.modalPresentationStyle = .fullScreen // Задаем стиль презентации
            present(authNavigationController, animated: false, completion: nil)
        }
    }
}

