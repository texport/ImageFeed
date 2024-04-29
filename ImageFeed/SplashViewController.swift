//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 22.03.2024.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    private let tokenStorage = OAuth2TokenStorage()
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "SplashScreenImage")
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("Splash screen appeared")
        if let token = tokenStorage.token {
            print("Token is available, fetching profile...")
            fetchProfile(token: token)
        } else {
            print("No token available, presenting auth...")
            presentAuth()
        }
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let profileData):
                    self?.presentGallery()
                    ProfileImageService.shared.fetchProfileImageURL(username: profileData.username) { _ in }
                case .failure:
                // TODO: Показать ошибку, если профиль не может быть загружен
                    self?.presentAuth()
                }
            }
        }
    }
    
    func didAuthenticate() {
        print("User did authenticate, presenting gallery...")
        presentGallery()
    }
    
    private func presentGallery() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: false, completion: nil)
    }
    
    private func presentAuth() {
        print("Attempting to present auth controller...")
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let authNavigationController = storyboard.instantiateViewController(withIdentifier: "AuthNavigationController") as? UINavigationController,
               let authViewController = authNavigationController.topViewController as? AuthViewController {
                authViewController.delegate = self
                print("Delegate is set: \(self)")
                authNavigationController.modalPresentationStyle = .fullScreen
                self.present(authNavigationController, animated: true, completion: {
                    print("Auth controller presented")
                })
            } else {
                print("Could not instantiate AuthNavigationController from storyboard")
            }
        }
    }
}
