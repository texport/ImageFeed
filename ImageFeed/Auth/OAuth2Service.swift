//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 21.03.2024.
//

import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    // формируем ссылку для запроса токена
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
    
    // запрашиваем токен
    func fetchOAuthToken(withCode code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = createTokenRequest(withCode: code) else {
            completion(.failure(NSError(domain: "OAuth2Service", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid request."])))
            return
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Сетевая ошибка: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 1, userInfo: [NSLocalizedDescriptionKey: "No response."])))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "OAuth2Service", code: 2, userInfo: [NSLocalizedDescriptionKey: "HTTP Error: \(httpResponse.statusCode)"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            } catch {
                DispatchQueue.main.async {
                    if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                        print("Ошибка сервиса Unsplash: HTTP статус \(httpResponse.statusCode)")
                    }
                    print("Ошибка декодирования: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
}
