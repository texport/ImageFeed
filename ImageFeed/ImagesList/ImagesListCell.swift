//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 19.02.2024.
//

import UIKit

@IBDesignable
final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    private let container = UIView()
    let customImageView = UIImageView()
    private let labelBackgroundView = UIView()
    private let customLabel = UILabel()
    let customButton = UIButton(type: .custom)
    
    var onLikeButtonTapped: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(named: "YP Black")
        setupViews()
        customButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.kf.cancelDownloadTask()  // Отмена загрузки изображений в customImageView
    }
    
    @objc private func likeButtonTapped() {
        let isLikedNow = !customButton.isSelected
        customButton.isSelected = isLikedNow
        let buttonImage = isLikedNow ? UIImage(named: "Active") : UIImage(named: "No Active")
        customButton.setImage(buttonImage, for: .normal)
        onLikeButtonTapped?(isLikedNow)
    }
        
    private func setupViews() {
        contentView.addSubview(container)
        container.translatesAutoresizingMaskIntoConstraints = false
        
        // констреинты контейнера
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8), // Верхний отступ
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8), // Нижний отступ
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16), // Левый отступ
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16), // Правый отступ
        ])
        
        container.addSubview(customImageView)
        container.addSubview(labelBackgroundView)
        container.addSubview(customLabel)
        container.addSubview(customButton)
        
        NSLayoutConstraint.activate([
            labelBackgroundView.leadingAnchor.constraint(equalTo: customLabel.leadingAnchor, constant: -10),
            labelBackgroundView.trailingAnchor.constraint(equalTo: customLabel.trailingAnchor, constant: 10),
            labelBackgroundView.topAnchor.constraint(equalTo: customLabel.topAnchor, constant: -5),
            labelBackgroundView.bottomAnchor.constraint(equalTo: customLabel.bottomAnchor, constant: 5),
            
            customImageView.topAnchor.constraint(equalTo: container.topAnchor),
            customImageView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            customImageView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            customImageView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            
            customLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            customLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            
            customButton.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            customButton.topAnchor.constraint(equalTo: container.topAnchor),
            customButton.widthAnchor.constraint(equalToConstant: 44), // Ширина кнопки
            customButton.heightAnchor.constraint(equalToConstant: 44), // Высота кнопки
        ])
        
        // Скругление углов ячейки
        container.layer.cornerRadius = 16
        container.clipsToBounds = true
        
        customImageView.layer.cornerRadius = 16
        customImageView.clipsToBounds = true
        
        setupGradientForLabel()
    }
    
    func configure(imageURL: String, labelText: String, isLiked: Bool) {
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        customImageView.contentMode = .scaleAspectFill
        customImageView.kf.setImage(
            with: URL(string: imageURL),
            placeholder: UIImage(named: "placeholder"),
            options: [
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        if customImageView.image == nil {
            print("[ImagesListCell]: Ошибка загрузки - Изображение по URL \(imageURL) не найдено.")
        }

        customLabel.translatesAutoresizingMaskIntoConstraints = false
        customLabel.textColor = .white
        customLabel.text = labelText

        customButton.translatesAutoresizingMaskIntoConstraints = false
//        let buttonImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
//        customButton.setImage(buttonImage, for: .normal)
        customButton.isSelected = isLiked // Установка начального состояния кнопки
        let buttonImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        customButton.setImage(buttonImage, for: .normal)

        print("[ImagesListCell]: Информация - Ячейка сконфигурирована с imageURL: \(imageURL), labelText: \(labelText), isLiked: \(isLiked)")
    }

    private func setupGradientForLabel() {
        labelBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        labelBackgroundView.layer.cornerRadius = 5 // радиус скругления
        labelBackgroundView.clipsToBounds = true
        
        // Создание градиентного слоя
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.red.cgColor, UIColor.orange.cgColor] // градиента от красного к оранжевому
        gradientLayer.locations = [0.0, 1.0] // Начальная и конечная точки градиента
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5) // Горизонтальный градиент
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // размер градиента будет настраивается в layoutSubviews
        labelBackgroundView.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let gradientLayer = labelBackgroundView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = labelBackgroundView.bounds
        }
        
        labelBackgroundView.layer.sublayers?.first?.frame = labelBackgroundView.bounds
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView?.isHidden = true  // Скрытие встроенного imageView
    }
}
