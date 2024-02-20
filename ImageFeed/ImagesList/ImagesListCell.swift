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
    private let customImageView = UIImageView()
    private let customLabel = UILabel()
    private let customButton = UIButton(type: .custom)
    
//    let customImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFill
//        return imageView
//    }()
//    
//    let customLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textColor = .white
//        label.text = "31 августа 2024"
//        return label
//    }()
//
//    let customButton: UIButton = {
//        let button = UIButton(type: .custom)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(named: "Active"), for: .normal)
//        return button
//    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = UIColor(named: "YP Black")
        setupViews()
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        container.addSubview(customLabel)
        container.addSubview(customButton)
        
        NSLayoutConstraint.activate([
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
    }
    
    func configure(imageName: String, labelText: String, isLiked: Bool) {
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        customImageView.contentMode = .scaleAspectFill
        customImageView.image = UIImage(named: imageName)
        
        customLabel.translatesAutoresizingMaskIntoConstraints = false
        customLabel.textColor = .white
        customLabel.text = labelText
        
        customButton.translatesAutoresizingMaskIntoConstraints = false
        let buttonImage = isLiked ? UIImage(named: "Active") : UIImage(named: "No Active")
        customButton.setImage(buttonImage, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
