//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 11.03.2024.
//

import ProgressHUD
import UIKit

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    weak var delegate: AuthViewControllerDelegate?
    
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        setupEnterButtonSetting()
        configureBackButton()
    }
    
    private func setupEnterButtonSetting() {
        enterButton.layer.cornerRadius = 16
        enterButton.layer.masksToBounds = true
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let webView = segue.destination as? WebViewViewController {
            webView.delegate = self
        }
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(withCode: code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let token):
                    let tokenStorage = OAuth2TokenStorage()
                    tokenStorage.token = token

                    self?.dismiss(animated: true) {
                        self?.delegate?.didAuthenticate()
                    }
                case .failure(let error):
                    print("Ошибка получения токена: \(error)")
                    self?.showErrorAlert("Не удалось войти в систему", message: "Пожалуйста, попробуйте еще раз.")
                }
            }
        }
    }

    private func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}