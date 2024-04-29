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
        if segue.identifier == "showWebView", let webViewVC = segue.destination as? WebViewViewController {
            webViewVC.delegate = self
            print("WebView delegate set: \(self)")
        }
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        // Проверяем, активен ли индикатор активности
        if UIBlockingProgressHUD.isVisible {
            print("Действие заблокировано: индикатор активности отображается")
        } else {
            // Если индикатор не активен, выполняем переход
            performSegue(withIdentifier: "showWebView", sender: self)
        }
    }
    
    // Методы делегата для обработки событий из WebViewViewController
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Auth delegate method called with code: \(code)")
        //UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(withCode: code) { [weak self] result in
            DispatchQueue.main.async {
                //UIBlockingProgressHUD.dismiss()
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
