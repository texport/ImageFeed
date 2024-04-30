//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 22.03.2024.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
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
        if let token = OAuth2TokenStorage.shared.token {
            fetchProfile(token: token)
        } else {
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
                    NotificationCenter.default.post(name: .didFetchProfileData, object: nil, userInfo: ["profileData": profileData])
                    self?.presentGallery()
                case .failure(let error):
                    print("[ProfileService]: Ошибка загрузки профиля - \(error.localizedDescription)")
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
