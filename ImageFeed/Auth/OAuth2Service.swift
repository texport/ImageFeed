import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let tokenQueue = DispatchQueue(label: "com.imagefeed.oauth2.tokenQueue")
    private var currentTask: URLSessionDataTask?

    private init() {}

    // Формируем ссылку для запроса токена
    private func createTokenRequest(withCode code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.tokenURLString) else { return nil }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }

    // Запрашиваем токен
    func fetchOAuthToken(withCode code: String, completion: @escaping (Result<String, Error>) -> Void) {
        tokenQueue.async {
            guard let request = self.createTokenRequest(withCode: code) else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request."])))
                }
                return
            }
            
            self.currentTask?.cancel() // Отменяем предыдущий запрос, если таковой есть
            
            let task = URLSession.shared.decodableTask(with: request) { (result: Result<OAuthTokenResponseBody, Error>) in
                switch result {
                case .success(let tokenResponse):
                    completion(.success(tokenResponse.accessToken))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
            self.currentTask = task // Сохраняем ссылку на текущий таск
            task.resume()
        }
    }
}
