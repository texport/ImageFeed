import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    var photos: [Photo] = []

    var imagesService = ImagesListService()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(updatePhotos), name: ImagesListService.didChangeNotification, object: nil)
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        imagesService.fetchPhotosNextPage()  // Запуск загрузки данных при первой загрузке
        print("[ImagesListViewController]: Вид загружен и настроен. Запущена загрузка фотографий.")
    }

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath, photo: Photo) {
        cell.customImageView.kf.indicatorType = .activity
        cell.customImageView.kf.setImage(
            with: URL(string: photo.largeImageURL),
            placeholder: UIImage(named: "placeholder"),
            options: [.transition(.fade(1)), .cacheOriginalImage]
        )
        cell.configure(imageURL: photo.largeImageURL, labelText: dateFormatter.string(from: photo.createdAt ?? Date()), isLiked: photo.isLiked)
        cell.onLikeButtonTapped = { [weak self] isLikedNow in
            guard let self = self else { return }
            let photoId = photo.id
            if isLikedNow {
                UIBlockingProgressHUD.show()
                self.imagesService.likePhoto(photoID: photoId) { result in
                    DispatchQueue.main.async {
                        UIBlockingProgressHUD.dismiss()
                        switch result {
                        case .success():
                            print("[ImagesListViewController]: Лайк установлен для \(photoId).")
                            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                                self.photos[index].isLiked = true
                                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                            }
                        case .failure(let error):
                            print("[ImagesListViewController]: Ошибка при установке лайка - \(error)")
                            cell.customButton.isSelected = false
                        }
                    }
                }
            } else {
                UIBlockingProgressHUD.show()
                self.imagesService.unlikePhoto(photoID: photoId) { result in
                    DispatchQueue.main.async {
                        UIBlockingProgressHUD.dismiss()
                        switch result {
                        case .success():
                            print("[ImagesListViewController]: Лайк снят для \(photoId).")
                            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                                self.photos[index].isLiked = false
                                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                            }
                        case .failure(let error):
                            print("[ImagesListViewController]: Ошибка при снятии лайка - \(error)")
                            cell.customButton.isSelected = true
                        }
                    }
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath {
            let photo = photos[indexPath.row]
            viewController.imageUrl = URL(string: photo.largeImageURL)  // Передача URL
            print("[ImagesListViewController]: Переход по segue с URL: \(photo.largeImageURL).")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    @objc func updatePhotos() {
        print("[ImagesListViewController]: Обновление фотографий по уведомлению.")
        photos = imagesService.photos
        tableView.performBatchUpdates({
            tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }, completion: nil)
    }
}

extension ImagesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
        print("[ImagesListViewController]: Выбрана ячейка с индексом \(indexPath.row).")
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let verticalPadding: CGFloat = 16 + 16 // 32 - вертикальный отступ
        let photo = photos[indexPath.row]
        let targetWidth = tableView.bounds.width - 32 // Ширина таблицы минус горизонтальные отступы
        let scaleRatio = targetWidth / photo.size.width
        let imageViewHeight = photo.size.height * scaleRatio
        return imageViewHeight + verticalPadding
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }

        let photo = photos[indexPath.row]
        configCell(for: cell, with: indexPath, photo: photo)
        return cell
    }
}

extension ImagesListViewController {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            imagesService.fetchPhotosNextPage()
            print("[ImagesListViewController]: Достигнут конец списка. Загрузка следующей страницы...")
        }
    }
}
