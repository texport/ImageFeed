import UIKit

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    weak var delegate: AuthViewControllerDelegate?
    
    @IBOutlet weak var enterButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupEnterButtonSettings()
        configureBackButton()
    }
    
    private func setupEnterButtonSettings() {
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
        print("Preparing for segue with identifier: \(segue.identifier ?? "nil")")
        if segue.identifier == "showWebView", let webViewVC = segue.destination as? WebViewViewController {
            webViewVC.delegate = self
            print("WebView delegate set: \(self)")
        }
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        if UIBlockingProgressHUD.isVisible {
            print("Action blocked: progress indicator is visible")
        } else {
            print("Performing segue to WebView")
            performSegue(withIdentifier: "showWebView", sender: self)
        }
    }
    
//    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
//        print("Auth delegate method called with code: \(code)")
//        UIBlockingProgressHUD.show()  // Показать индикатор прогресса
//
//        OAuth2Service.shared.fetchOAuthToken(withCode: code) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let token):
//                    OAuth2TokenStorage.shared.token = token
//
//                    vc.dismiss(animated: false) {
//                        print("WebView is closed.")
//                        self?.dismiss(animated: true) {
//                            print("AuthViewController is closed.")
//                            self?.delegate?.didAuthenticate()
//                        }
//                    }
//                case .failure(let error):
//                    print("Ошибка получения токена: \(error)")
//                    self?.showErrorAlert("Не удалось войти в систему", message: "Пожалуйста, попробуйте еще раз.")
//                    UIBlockingProgressHUD.dismiss()  // Скрыть индикатор, если процесс не удался
//                }
//            }
//        }
//    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(withCode: code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let token):
                    OAuth2TokenStorage.shared.token = token
                    self?.dismiss(animated: true) {
                        self?.delegate?.didAuthenticate()
                    }
                case .failure(let error):
                    self?.showErrorAlert()
                    print("[OAuth2Service]: Ошибка получения токена - \(error.localizedDescription)")
                }
            }
        }
    }

    private func showErrorAlert() {
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
    
    private func showErrorAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    deinit {
        print("AuthViewController is being deinitialized")
    }
}
