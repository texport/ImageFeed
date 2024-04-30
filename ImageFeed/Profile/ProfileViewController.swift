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
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileImage(_:)), name: .didFetchProfileImage, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateProfileData(_:)), name: .didFetchProfileData, object: nil)
        
        if let avatarURL = ProfileImageService.shared.avatarURL {
            loadImageFromURL(avatarURL)	
        }
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
            print("Данные профиля не загружены")
            return
        }

        nameLabel.text = profileData.name
        usernameLabel.text = profileData.loginName
        descriptionLabel.text = profileData.bio

        // Загрузка изображения профиля, если URL доступен
        if let urlString = profileData.avatarURL, let url = URL(string: urlString) {
            profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "default-avatar"), options: [.transition(.fade(0.2))])
        }
    }

    private func fetchProfileData() {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("Токен доступа не найден")
            return
        }
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileData):
                    self?.updateProfileDetails()
                case .failure(let error):
                    print("Ошибка при загрузке данных профиля: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func updateProfileData(_ notification: Notification) {
        if let profileData = notification.userInfo?["profileData"] as? ProfileUIData {
            nameLabel.text = profileData.name
            usernameLabel.text = profileData.loginName
            descriptionLabel.text = profileData.bio
            if let urlString = profileData.avatarURL, let url = URL(string: urlString) {
                profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "default-avatar"), options: [.transition(.fade(0.2))])
            }
        }
    }
    
    private func loadImageFromURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Не удалось извлечь URL аватара из уведомления.")
            return
        }
        profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "default-avatar"), options: [.transition(.fade(0.2))])
    }

//    @objc private func updateProfileImage(_ notification: Notification) {
//        guard let userInfo = notification.userInfo,
//              let avatarURLString = userInfo["avatarURL"] as? String,
//              let url = URL(string: avatarURLString) else {
//            print("Не удалось извлечь URL аватара из уведомления.")
//            return
//        }
//        
//        print("Получен URL аватара: \(avatarURLString)")
//        // Использование Kingfisher для загрузки изображения
//        profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "default-avatar"), options: [.transition(.fade(0.2))]) {
//            result in
//            switch result {
//            case .success(let imageResult):
//                print("Аватарка успешно загружена: \(imageResult.image)")
//            case .failure(let error):
//                print("Ошибка загрузки аватарки: \(error.localizedDescription)")
//            }
//        }
//    }
    
    @objc private func updateProfileImage(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let avatarURLString = userInfo["avatarURL"] as? String,
              let url = URL(string: avatarURLString) else {
            print("Не удалось извлечь URL аватара из уведомления.")
            return
        }
        
        print("Получен URL аватара: \(avatarURLString)")
        profileImageView.kf.setImage(with: url, placeholder: UIImage(named: "default-avatar"), options: [.transition(.fade(0.2))])
    }

    
    @objc private func handleLogoutTap() {
        // Удаление токена из хранилища
        let tokenStorage = OAuth2TokenStorage.shared
        tokenStorage.token = nil
        print("Вы вышли из системы, токен удалён")

        // Перезагрузка экрана входа через SplashViewController, созданного программно
        if let window = UIApplication.shared.windows.first {
            let splashViewController = SplashViewController() // Создание SplashViewController программно
            window.rootViewController = splashViewController
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func startSetupProfileImage() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        //profileImageView.contentMode = .scaleAspectFit
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
