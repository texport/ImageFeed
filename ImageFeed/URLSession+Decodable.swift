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
                    print("[URLSession+Decodable]: Ошибка сети - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    print("[URLSession+Decodable]: Ошибка HTTP - Код ошибки \(statusCode)")
                    completion(.failure(NetworkError.responseUnsuccessful(description: "Сервер вернул код ответа \(statusCode).")))
                    return
                }

                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("[URLSession+Decodable]: Ошибка декодирования - \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "N/A")")
                    completion(.failure(NetworkError.jsonDecodingFailure(description: "Ошибка при декодировании JSON: \(error.localizedDescription).")))
                }
            }
        }
        return task
    }
}

enum NetworkError: Error {
    case responseUnsuccessful(description: String)
    case invalidData(description: String)
    case jsonDecodingFailure(description: String)
    case invalidURL(description: String)
    case invalidToken(description: String) // Добавлен новый кейс для ошибки с токеном
    case invalidResponse(description: String)
}
