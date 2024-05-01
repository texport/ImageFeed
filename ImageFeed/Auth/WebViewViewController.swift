import UIKit
import WebKit
import Combine

final class WebViewViewController: UIViewController, WKNavigationDelegate {
    weak var delegate: WebViewViewControllerDelegate?
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    
    private var progressObserver: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        setupProgressObserver()
        loadAuthView()
    }

    private func setupProgressObserver() {
        progressObserver = webView.publisher(for: \.estimatedProgress)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] progress in
                self?.progressView.progress = Float(progress)
                self?.progressView.isHidden = progress == 1.0
            }
    }

    private func loadAuthView() {
        guard var urlComponent = URLComponents(string: Constants.unsplashAuthorizeURLString) else {
            return
        }
        
        urlComponent.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponent.url else {
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        delegate?.webViewViewControllerDidCancel(self)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            print("[WebViewViewController]: Информация - Получен код авторизации: \(code)")
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        } else {
            return nil
        }
    }

    deinit {
        progressObserver?.cancel()
        print("[WebViewViewController]: Информация - WebViewViewController деинициализируется")
    }
}
