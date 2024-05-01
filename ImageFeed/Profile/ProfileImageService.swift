import UIKit

final class ProfileImageService {
    static let shared = ProfileImageService()
    private(set) var avatarURL: String?
    private var isFetching = false

    private init() {}

    struct UserResult: Codable {
        let profile_image: ProfileImageURLs
    }

    struct ProfileImageURLs: Codable {
        let large: String
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        guard !isFetching else {
            print("[ProfileImageService]: Ошибка - Запрос на получение изображения уже выполняется.")
            completion(.failure(NSError(domain: "ProfileImageService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Already fetching."])))
            return
        }

        if let cachedURL = avatarURL {
            print("[ProfileImageService]: Информация - URL изображения получен из кэша.")
            completion(.success(cachedURL))
            return
        }

        guard let token = OAuth2TokenStorage.shared.token else {
            print("[ProfileImageService]: Ошибка - Требуется аутентификация для получения URL изображения.")
            completion(.failure(NSError(domain: "ProfileImageService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Authentication required."])))
            return
        }

        isFetching = true

        guard let request = createProfileImageRequest(username: username, token: token) else {
            isFetching = false
            print("[ProfileImageService]: Ошибка - Не удалось создать запрос на получение URL изображения.")
            completion(.failure(NSError(domain: "ProfileImageService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unable to create request."])))
            return
        }

        let task = URLSession.shared.decodableTask(with: request) { [weak self] (result: Result<UserResult, Error>) in
            defer { self?.isFetching = false }
            switch result {
            case .success(let userResult):
                let avatarURLString = userResult.profile_image.large
                self?.avatarURL = avatarURLString // Cache the URL
                
                NotificationCenter.default.post(name: .didFetchProfileImage, object: nil, userInfo: ["avatarURL": avatarURLString])
                
                print("[ProfileImageService]: Информация - URL аватара успешно получен и отправлен в уведомлении.")
                completion(.success(avatarURLString))
            case .failure(let error):
                print("[ProfileImageService]: Ошибка - Не удалось загрузить URL аватара: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }

    private func createProfileImageRequest(username: String, token: String) -> URLRequest? {
        let urlString = "https://api.unsplash.com/users/\(username)"
        guard let url = URL(string: urlString) else {
            print("[ProfileImageService]: Ошибка - Некорректный URL.")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
}

extension Notification.Name {
    static let didFetchProfileImage = Notification.Name("didFetchProfileImage")
    static let didFetchProfileData = Notification.Name("didFetchProfileData")
}
