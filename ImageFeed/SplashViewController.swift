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
                    self?.fetchAvatarUrl(username: profileData.username)
                    self?.presentGallery()
                case .failure(let error):
                    print("[SplashViewController]: Ошибка загрузки профиля - \(error.localizedDescription)")
                    self?.presentAuth()
                }
            }
        }
    }
    
    private func fetchAvatarUrl(username: String) {
        UIBlockingProgressHUD.show()
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let avatarData):
                    print("[SplashViewController]: Аватарка загружена - \(avatarData)")
                case .failure(let error):
                    print("[SplashViewController]: Ошибка загрузки аватарки - \(error.localizedDescription)")
                }
            }
        }
    }

    func didAuthenticate() {
        print("[SplashViewController]: Информация - Пользователь аутентифицирован, отображение галереи.")
        presentGallery()
    }
    
    private func presentGallery() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: false, completion: nil)
    }
    
    private func presentAuth() {
        print("[SplashViewController]: Информация - Попытка отобразить контроллер аутентификации.")
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let authNavigationController = storyboard.instantiateViewController(withIdentifier: "AuthNavigationController") as? UINavigationController,
               let authViewController = authNavigationController.topViewController as? AuthViewController {
                authViewController.delegate = self
                authNavigationController.modalPresentationStyle = .fullScreen
                self.present(authNavigationController, animated: true, completion: {
                    print("[SplashViewController]: Информация - Контроллер аутентификации представлен.")
                })
            } else {
                print("[SplashViewController]: Ошибка - Не удалось инстанциировать AuthNavigationController из storyboard.")
            }
        }
    }
}
