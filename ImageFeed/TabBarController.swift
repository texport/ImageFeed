//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Sergey Ivanov on 28.04.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Настройка внешнего вида таб бара
        tabBar.tintColor = .white // Цвет иконок когда они выбраны
        tabBar.unselectedItemTintColor = .ypGray // Цвет иконок когда они не выбраны
        tabBar.barTintColor = .ypBlack // Цвет фона таб бара
        
        // Создаем ImagesListViewController из storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListVC = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        imagesListVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tab_editorial_active"), selectedImage: nil)
        
        // Создаем ProfileViewController программно
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "tab_profile_active"), selectedImage: nil)
        
        // Устанавливаем контроллеры для таб бара
        self.viewControllers = [imagesListVC, profileVC]
    }
}

