//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 20.02.2024.
//

import Kingfisher
import UIKit

final class ProfileViewController: UIViewController {
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let usernameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let logoutButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startSetupProfileImage()
        startSetupNameProfile()
        startSetupTagNameProfile()
        startSetupDescriptionProfile()
        startSetupExitButton()
        updateProfileDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileData(_:)), name: .didFetchProfileData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateAvatarUserUI(_:)), name: .didFetchProfileData, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Установка скругленных углов для изображения
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
    }
    
    private func updateProfileDetails() {
        guard let profileData = ProfileService.shared.profile else {
            print("[ProfileViewController]: Ошибка - Данные профиля не загружены")
            return
        }

        nameLabel.text = profileData.name
        usernameLabel.text = profileData.loginName
        descriptionLabel.text = profileData.bio
        

        // Загрузка изображения профиля, если URL доступен
        if let urlString = ProfileImageService.shared.avatarURL {
            loadImageFromURL(urlString)
        }
    }

    @objc private func updateProfileData(_ notification: Notification) {
        if let profileData = notification.userInfo?["profileData"] as? ProfileUIData {
            nameLabel.text = profileData.name
            usernameLabel.text = profileData.loginName
            descriptionLabel.text = profileData.bio
        }
    }
    
    @objc private func updateAvatarUserUI(_ notification: Notification) {
        if let avatarURL = notification.userInfo?["avatarURL"] as? String {
            loadImageFromURL(avatarURL)
        }
    }
    
    private func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("[ProfileViewController]: Ошибка - Не удалось извлечь URL аватара из уведомления.")
            return
        }
        profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "Photo"), options: [.transition(.fade(0.2))])
        print("[ProfileViewController]: Автарат обновлен")
    }

//    @objc private func handleLogoutTap() {
//        // Удаление токена из хранилища
//        let tokenStorage = OAuth2TokenStorage.shared
//        tokenStorage.token = nil
//        print("[ProfileViewController]: Информация - Вы вышли из системы, токен удалён")
//
//        // Перезагрузка экрана входа через SplashViewController, созданного программно
//        if let window = UIApplication.shared.windows.first {
//            let splashViewController = SplashViewController() // Создание SplashViewController программно
//            window.rootViewController = splashViewController
//            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
//        }
//    }
    
    @objc private func handleLogoutTap() {
        let alert = UIAlertController(title: "Пока, пока!", message: "Вы уверены, что хотите выйти?", preferredStyle: .alert)
        
        // Добавляем кнопку "Да" (выход)
        let yesAction = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
            // Удаление токена из хранилища OAuth2TokenStorage
            let tokenStorage = OAuth2TokenStorage.shared
            tokenStorage.token = nil
            print("[ProfileViewController]: Информация - Вы вышли из системы, токен удалён")

            // Перезагрузка экрана входа через SplashViewController, созданного программно
            if let window = UIApplication.shared.windows.first {
                let splashViewController = SplashViewController() // Создание SplashViewController программно
                window.rootViewController = splashViewController
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
        alert.addAction(yesAction)
        
        // Добавляем кнопку "Нет" (отмена)
        let noAction = UIAlertAction(title: "Нет", style: .cancel, handler: nil)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func startSetupProfileImage() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageView.frame.width
        profileImageView.image = UIImage(named: "Photo")
        
        view.addSubview(profileImageView)
        
        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 52),
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func startSetupNameProfile() {
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = "Екатерина Новикова"
        nameLabel.textColor = .white
        nameLabel.font = UIFont.boldSystemFont(ofSize: 23)
        
        view.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),
            nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func startSetupTagNameProfile() {
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.text = "@ekaterina_nov"
        usernameLabel.textColor = .ypGray
        usernameLabel.font = UIFont.systemFont(ofSize: 13)
        
        view.addSubview(usernameLabel)
        
        NSLayoutConstraint.activate([
            usernameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            usernameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func startSetupDescriptionProfile() {
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.systemFont(ofSize: 13)
        
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
    
    private func startSetupExitButton() {
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setImage(UIImage(named: "Exit"), for: .normal)
        logoutButton.addTarget(self, action: #selector(handleLogoutTap), for: .touchUpInside) // Добавление обработчика нажатия
        
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 75),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            logoutButton.widthAnchor.constraint(equalToConstant: 24),
            logoutButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
