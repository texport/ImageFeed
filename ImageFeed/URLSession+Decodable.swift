//
//  URLSession+Decodable.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 28.04.2024.
//

import UIKit

extension URLSession {
    func decodableTask<T: Decodable>(
        with request: URLRequest,
        decoder: JSONDecoder = JSONDecoder(),
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionDataTask {
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Логирование сетевой ошибки
                    print("[decodableTask]: Networking Error - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    // Логирование ошибки сервера
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    print("[decodableTask]: HTTP Error - код ошибки \(statusCode)")
                    completion(.failure(NetworkError.responseUnsuccessful))
                    return
                }

                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    // Логирование ошибки декодирования
                    print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                    completion(.failure(error))
                }
            }
        }
        return task
    }
}

enum NetworkError: Error {
    case responseUnsuccessful
    case invalidData
    case jsonDecodingFailure
}
