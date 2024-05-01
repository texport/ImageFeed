import UIKit

final class ImagesListViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    let images: [String] = (0..<20).map { "\($0)" }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ImagesListCell.self, forCellReuseIdentifier: ImagesListCell.reuseIdentifier)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        let imageName = images[indexPath.row]
        
        guard let image = UIImage(named: imageName) else {
            print("[ImagesListViewController]: Ошибка загрузки - Изображение с именем \(imageName) не найдено.")
            return
        }
        
        cell.configure(imageName: imageName, labelText: dateFormatter.string(from: Date()), isLiked: indexPath.row % 2 == 0)
        print("[ImagesListViewController]: Информация - Конфигурация ячейки для изображения с индексом \(indexPath.row)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            let image = UIImage(named: images[indexPath.row])
            viewController.image = image
            print("[ImagesListViewController]: Информация - Переход по segue с идентификатором \(showSingleImageSegueIdentifier) для изображения с индексом \(indexPath.row)")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension ImagesListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let verticalPadding: CGFloat = 16 + 16
        
        guard let image = UIImage(named: images[indexPath.row]) else {
            return verticalPadding + 200
        }
        
        let targetWidth = tableView.bounds.width - (16 + 16)
        let scaleRatio = targetWidth / image.size.width
        let imageViewHeight = image.size.height * scaleRatio
        return imageViewHeight + verticalPadding
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: cell, with: indexPath)
        return cell
    }
}
