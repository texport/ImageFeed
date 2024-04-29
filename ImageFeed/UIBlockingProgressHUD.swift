import ProgressHUD
import UIKit

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    static var isVisible = false // Добавляем свойство для отслеживания видимости

    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
        isVisible = true // Устанавливаем флаг видимости в true
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
        isVisible = false // Сбрасываем флаг видимости
    }
}
