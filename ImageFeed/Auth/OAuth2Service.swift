import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let tokenQueue = DispatchQueue(label: "com.imagefeed.oauth2.tokenQueue")
    private var currentTask: URLSessionDataTask?

    private init() {}

    // Формируем ссылку для запроса токена
    private func createTokenRequest(withCode code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.tokenURLString) else {
            print("[OAuth2Service]: Ошибка - Неверный URL для токена")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("[OAuth2Service]: Ошибка - Невозможно создать URL с компонентами")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        print("[OAuth2Service]: Информация - Создан запрос на получение токена")
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
            print("[OAuth2Service]: Информация - Предыдущий запрос на токен отменен")
            
            let task = URLSession.shared.decodableTask(with: request) { (result: Result<OAuthTokenResponseBody, Error>) in
                switch result {
                case .success(let tokenResponse):
                    completion(.success(tokenResponse.accessToken))
                    print("[OAuth2Service]: Информация - Токен успешно получен")
                case .failure(let error):
                    completion(.failure(error))
                    print("[OAuth2Service]: Ошибка - Не удалось получить токен: \(error.localizedDescription)")
                }
            }
            self.currentTask = task // Сохраняем ссылку на текущий таск
            task.resume()
        }
    }
}
