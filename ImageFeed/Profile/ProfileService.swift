import UIKit

final class ProfileService {
    static let shared = ProfileService()
    private(set) var profile: ProfileUIData? // Сохраняем последний успешный результат запроса профиля

    private init() {}

    private func createProfileRequest(withToken token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("[ProfileService]: Ошибка - Некорректный URL для запроса данных профиля")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("[ProfileService]: Информация - Создан запрос для получения данных профиля")
        return request
    }

    // Метод для получения профиля пользователя
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileUIData, Error>) -> Void) {
        guard let request = createProfileRequest(withToken: token) else {
            let error = NSError(domain: "ProfileService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL or token."])
            print("[ProfileService]: Ошибка - Некорректный URL или токен.")
            completion(.failure(error))
            return
        }

        let task = URLSession.shared.decodableTask(with: request) { [weak self] (result: Result<ProfileResponseBody, Error>) in
            switch result {
            case .success(let profileResponse):
                let nameToUse = profileResponse.name ?? [profileResponse.firstName, profileResponse.lastName].compactMap { $0 }.joined(separator: " ")
                let profileData = ProfileUIData(
                    username: profileResponse.username,
                    name: nameToUse,
                    loginName: "@\(profileResponse.username)",
                    bio: profileResponse.bio
                )
                self?.profile = profileData // Сохраняем данные профиля
                print("[ProfileService]: Информация - Профиль пользователя успешно получен и сохранён.")
                NotificationCenter.default.post(name: .didFetchProfileData, object: nil, userInfo: ["profileData": profileData])
                completion(.success(profileData))
            case .failure(let error):
                print("[ProfileService]: Ошибка - Не удалось получить данные профиля: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
