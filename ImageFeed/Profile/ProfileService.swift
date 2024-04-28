import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: ProfileUIData? // Сохраняем последний успешный результат запроса профиля

    private init() {}

    // Создание запроса для получения профиля пользователя
    private func createProfileRequest(withToken token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    // Метод для получения профиля пользователя
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileUIData, Error>) -> Void) {
        guard let request = createProfileRequest(withToken: token) else {
            completion(.failure(NSError(domain: "ProfileService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token."])))
            return
        }

        let task = URLSession.shared.decodableTask(with: request) { [weak self] (result: Result<ProfileResponseBody, Error>) in
            switch result {
            case .success(let profileResponse):
                // Создаем ProfileUIData из полученного ответа
                let nameToUse = profileResponse.name ?? [profileResponse.firstName, profileResponse.lastName].compactMap { $0 }.joined(separator: " ")
                let profileData = ProfileUIData(
                    username: profileResponse.username,
                    name: nameToUse,
                    loginName: "@\(profileResponse.username)",
                    bio: profileResponse.bio
                )
                self?.profile = profileData // Сохраняем данные профиля
                completion(.success(profileData))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
