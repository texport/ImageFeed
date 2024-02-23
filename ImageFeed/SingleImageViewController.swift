//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 20.02.2024.
//

import UIKit

class SingleImageViewController: UIViewController {
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView.image = image
        }
    }
    
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
        
        scrollView.delegate = self
        imageView.contentMode = .scaleAspectFit
        
        if let image = image {
            imageView.image = image
            configureScrollViewInitialZoom()
        }
    }
    
    func configureScrollViewInitialZoom() {
        guard let image = imageView.image, scrollView.zoomScale == scrollView.minimumZoomScale else { return }

        let widthScale = scrollView.frame.size.width / image.size.width
        let heightScale = scrollView.frame.size.height / image.size.height
        let initialScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = initialScale
        scrollView.zoomScale = initialScale
        scrollView.maximumZoomScale = 4.0

        centerImage()
    }

    func centerImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size

        let verticalPadding = max(0, (scrollViewSize.height - imageViewSize.height) / 2)
        let horizontalPadding = max(0, (scrollViewSize.width - imageViewSize.width) / 2)

        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // настройка масштаба и центрирования здесь,
        // чтобы убедиться, что scrollView и imageView уже имеют окончательные размеры
        configureScrollViewInitialZoom()
    }
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image = imageView.image else { return }

        let activityViewController = UIActivityViewController(activityItems: [image],
                                                              applicationActivities: nil)

        // Исключаем некоторые типы действий, если необходимо
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.addToReadingList,
                                                        UIActivity.ActivityType.postToVimeo]

        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: imageView)
        
        // Немного увеличиваем, но не до максимума
        let zoomScaleFactor: CGFloat = min(scrollView.maximumZoomScale / 2, scrollView.zoomScale * 2)
        
        if scrollView.zoomScale != scrollView.minimumZoomScale {
            // Если текущий масштаб не минимальный, возвращаем к минимальному
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            // Рассчитываем размер прямоугольника для увеличения
            let scrollViewSize = scrollView.bounds.size
            let w = scrollViewSize.width / zoomScaleFactor
            let h = scrollViewSize.height / zoomScaleFactor
            let x = pointInView.x - (w / 2.0)
            let y = pointInView.y - (h / 2.0)
            
            let rectToZoomTo = CGRect(x: x, y: y, width: w, height: h)
            
            // Увеличиваем область вокруг точки нажатия
            scrollView.zoom(to: rectToZoomTo, animated: true)
        }
    }
}
