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
        view.backgroundColor = .clear
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "Logo_of_Unsplash")
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 100),
            imageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let token = tokenStorage.token {
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
        presentGallery()
    }
    
    private func presentGallery() {
        // Создаем экземпляр TabBarController
        let tabBarController = TabBarController()
        
        // Настраиваем стиль презентации
        tabBarController.modalPresentationStyle = .fullScreen
        
        // Показываем TabBarController
        present(tabBarController, animated: false, completion: nil)
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

