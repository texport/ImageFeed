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
        print("[AuthViewController]: Информация - Подготовка к переходу с идентификатором: \(segue.identifier ?? "nil")")
        if segue.identifier == "showWebView", let webViewVC = segue.destination as? WebViewViewController {
            webViewVC.delegate = self
            print("[AuthViewController]: Информация - Делегат WebView установлен: \(self)")
        }
    }
    
    @IBAction func enterButtonTapped(_ sender: Any) {
        if UIBlockingProgressHUD.isVisible {
            print("[AuthViewController]: Блокировка действия - Индикатор прогресса видим")
        } else {
            print("[AuthViewController]: Информация - Выполнение перехода к WebView")
            performSegue(withIdentifier: "showWebView", sender: self)
        }
    }
    
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
        print("[AuthViewController]: Информация - AuthViewController деинициализируется")
    }
}
