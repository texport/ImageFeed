import UIKit
import Kingfisher

final class SingleImageViewController: UIViewController {
    var imageUrl: URL? {
        didSet {
            print("[SingleImageViewController]: Попытка установить URL изображения: \(String(describing: imageUrl))")
            guard isViewLoaded else {
                print("[SingleImageViewController]: Представление контроллера еще не загружено.")
                return
            }
            
            UIBlockingProgressHUD.show()
            
            imageView.kf.setImage(
                with: imageUrl,
                placeholder: UIImage(named: "placeholder"),
                options: [
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ]) { result in
                    UIBlockingProgressHUD.dismiss()
                    switch result {
                    case .success(_):
                        print("[SingleImageViewController]: Изображение загружено успешно.")
                    case .failure(let error):
                        print("[SingleImageViewController]: Ошибка при загрузке изображения - \(error)")
                    }
                }
            print("[SingleImageViewController]: Настройка изображения с URL: \(String(describing: imageUrl)).")
        }
    }
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[SingleImageViewController]: viewDidLoad вызван.")
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        scrollView.delegate = self
        imageView.contentMode = .scaleAspectFit
        
        if let url = imageUrl {
            UIBlockingProgressHUD.show()
            imageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "placeholder"),
                options: [
                    .transition(.fade(1)),
                    .cacheOriginalImage
                ]) { result in
                    UIBlockingProgressHUD.dismiss() // Скрыть лоадер после завершения загрузки изображения
                    switch result {
                    case .success(_):
                        print("[SingleImageViewController]: Изображение загружено успешно.")
                    case .failure(let error):
                        print("[SingleImageViewController]: Ошибка при загрузке изображения - \(error)")
                    }
                }
                print("[SingleImageViewController]: Изображение настраивается в viewDidLoad с URL: \(url).")
            }
        configureScrollViewInitialZoom()
    }
    
    func configureScrollViewInitialZoom() {
        guard let image = imageView.image, scrollView.zoomScale == scrollView.minimumZoomScale else {
            print("[SingleImageViewController]: Настройка начального масштаба пропущена, так как изображение не загружено.")
            return
        }

        let widthScale = scrollView.frame.size.width / image.size.width
        let heightScale = scrollView.frame.size.height / image.size.height
        let initialScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = initialScale
        scrollView.zoomScale = initialScale
        scrollView.maximumZoomScale = 4.0

        centerImage()
        print("[SingleImageViewController]: Начальный масштаб настроен.")
    }

    func centerImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        let verticalPadding = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalPadding = max(0, (scrollViewSize.width - imageViewSize.width) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
        print("[SingleImageViewController]: Изображение центрировано.")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureScrollViewInitialZoom()
        print("[SingleImageViewController]: Перенастройка масштаба и центрирования после изменения размеров видов.")
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        print("[SingleImageViewController]: Нажата кнопка 'Назад'.")
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }

        let activityViewController = UIActivityViewController(activityItems: [image],
                                                              applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList,
                                                        UIActivity.ActivityType.postToVimeo]
        self.present(activityViewController, animated: true, completion: nil)
        print("[SingleImageViewController]: Нажата кнопка 'Поделиться'.")
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
        print("[SingleImageViewController]: Происходит масштабирование изображения.")
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: imageView)
        let zoomScaleFactor: CGFloat = min(scrollView.maximumZoomScale / 2, scrollView.zoomScale * 2)
        
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            print("[SingleImageViewController]: Уменьшение до минимального масштаба.")
        } else {
            let scrollViewSize = scrollView.bounds.size
            let w = scrollViewSize.width / zoomScaleFactor
            let h = scrollViewSize.height / zoomScaleFactor
            let x = pointInView.x - (w / 2.0)
            let y = pointInView.y - (h / 2.0)

            let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
            scrollView.zoom(to: rectToZoomTo, animated: true)
            print("[SingleImageViewController]: Увеличение области вокруг точки нажатия.")
        }
    }
}
