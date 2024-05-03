import UIKit

final class ImagesListService {
    static let didChangeNotification = Notification.Name("ImagesListServiceDidChange")

    private(set) var photos: [Photo] = []
    private var isFetching = false
    private var currentPage = 0

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // ISO 8601 формат
        return formatter
    }()

    func fetchPhotosNextPage() {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService]: Ошибка - Отсутствует токен OAuth2.")
            isFetching = false
            return
        }

        guard !isFetching else {
            print("[ImagesListService]: Информация - Загрузка уже в процессе.")
            return
        }
        isFetching = true
        currentPage += 1

        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(currentPage)&per_page=10&order_by=latest") else {
            print("[ImagesListService]: Ошибка - Неверный URL.")
            isFetching = false
            return
        }

        var request = URLRequest(url: url)
        //request.addValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let task = URLSession.shared.decodableTask(with: request, decoder: decoder) { [weak self] (result: Result<[PhotoResult], Error>) in
            DispatchQueue.main.async {
                self?.isFetching = false
                switch result {
                case .success(let photoResults):
                    let newPhotos = photoResults.map {
                        Photo(id: $0.id,
                              size: CGSize(width: $0.width, height: $0.height),
                              createdAt: self?.dateFormatter.date(from: $0.createdAt),
                              welcomeDescription: $0.description,
                              thumbImageURL: $0.urls.thumb.absoluteString,
                              largeImageURL: $0.urls.full.absoluteString,
                              isLiked: $0.likedByUser)
                    }
                    self?.photos.append(contentsOf: newPhotos)
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
                    print("[ImagesListService]: Информация - Фотографии успешно загружены и добавлены.")
                case .failure(let error):
                    print("[ImagesListService]: Ошибка - Не удалось загрузить или декодировать фотографии: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
    }
}

extension ImagesListService {
    func unlikePhoto(photoID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService]: Ошибка - Отсутствует токен OAuth2.")
            completion(.failure(NetworkError.invalidToken(description: "Отсутствует токен OAuth2.")))
            return
        }

        let unlikeURLString = "https://api.unsplash.com/photos/\(photoID)/like"
        guard let unlikeURL = URL(string: unlikeURLString) else {
            print("[ImagesListService]: Ошибка - Неверный URL для запроса на удаление лайка.")
            completion(.failure(NetworkError.invalidURL(description: "Неверный URL для запроса на удаление лайка.")))
            return
        }

        var request = URLRequest(url: unlikeURL)
        request.httpMethod = "DELETE"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[ImagesListService]: Ошибка сети - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[ImagesListService]: Ошибка - Отсутствует HTTP-ответ.")
                    completion(.failure(NetworkError.invalidResponse(description: "Отсутствует HTTP-ответ.")))
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    print("[ImagesListService]: Информация - Лайк успешно удалён.")
                    completion(.success(()))
                } else {
                    print("[ImagesListService]: Ошибка HTTP - Код ошибки \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.responseUnsuccessful(description: "Ошибка HTTP: \(httpResponse.statusCode)")))
                }
            }
        }
        task.resume()
    }
}

extension ImagesListService {
    func likePhoto(photoID: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ImagesListService]: Ошибка - Отсутствует токен OAuth2.")
            completion(.failure(NetworkError.invalidToken(description: "Отсутствует токен OAuth2.")))
            return
        }

        let likeURLString = "https://api.unsplash.com/photos/\(photoID)/like"
        guard let likeURL = URL(string: likeURLString) else {
            print("[ImagesListService]: Ошибка - Неверный URL для запроса на лайк.")
            completion(.failure(NetworkError.invalidURL(description: "Неверный URL для запроса на лайк.")))
            return
        }

        var request = URLRequest(url: likeURL)
        request.httpMethod = "POST"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Выполнение запроса с использованием вашего расширения URLSession
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("[ImagesListService]: Ошибка сети - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    print("[ImagesListService]: Ошибка - Отсутствует HTTP-ответ.")
                    completion(.failure(NetworkError.invalidResponse(description: "Отсутствует HTTP-ответ.")))
                    return
                }

                if (200...299).contains(httpResponse.statusCode) {
                    print("[ImagesListService]: Информация - Фото успешно отмечено как понравившееся.")
                    completion(.success(()))
                } else {
                    print("[ImagesListService]: Ошибка HTTP - Код ошибки \(httpResponse.statusCode)")
                    completion(.failure(NetworkError.responseUnsuccessful(description: "Ошибка HTTP: \(httpResponse.statusCode)")))
                }
            }
        }
        task.resume()
    }
}
