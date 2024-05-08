import XCTest

class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
        print("Приложение запущено.")
    }
    
    func testAuth() throws {
        app.buttons["Authenticate"].tap()
        
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText("№№№№")
        webView.swipeUp()
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        passwordTextField.typeText("№№№№")
        webView.swipeUp()
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }
    
//    func testFeed() throws {
//        let tablesQuery = app.tables
//        
//        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
//        cell.swipeUp()
//        
//        sleep(2)
//        
//        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
//        
//        cellToLike.buttons["likebutton"].tap()
//        cellToLike.buttons["likebutton"].tap()
//        
//        sleep(2)
//        
//        cellToLike.tap()
//        
//        sleep(2)
//        
//        let image = app.scrollViews.images.element(boundBy: 0)
//        // Zoom in
//        image.pinch(withScale: 3, velocity: 1) // zoom in
//        // Zoom out
//        image.pinch(withScale: 0.5, velocity: -1)
//        
//        let navBackButtonWhiteButton = app.buttons["nav back button white"]
//        navBackButtonWhiteButton.tap()
//    }
    
    func testFeed() throws {
        sleep(5)
        let tablesQuery = app.tables
        sleep(5)
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        XCTAssertTrue(cellToLike.waitForExistence(timeout: 5), "Желаемая ячейка не найдена или не загрузилась.")
        XCTAssertTrue(cellToLike.isHittable, "Кнопка 'likebutton' не доступна для нажатия.")

        cellToLike.buttons["likebutton"].tap()
        sleep(3)  // Дать время для обработки лайка
        cellToLike.buttons["likebutton"].tap()
        
        sleep(1)  // Дать время для обновления состояния лайка
        
        cellToLike.tap()
        sleep(1)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        image.pinch(withScale: 3, velocity: 1)  // Zoom in
        image.pinch(withScale: 0.5, velocity: -1)  // Zoom out
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        XCTAssertTrue(navBackButtonWhiteButton.isHittable, "Кнопка навигации назад не доступна.")
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // Даем приложению время для стабилизации состояния перед началом теста
        sleep(3)
        // Переход на вкладку профиля
        app.tabBars.buttons.element(boundBy: 1).tap()
        
        // Проверяем, что профиль загружен правильно
        XCTAssertTrue(app.staticTexts["Sergey Ivanov"].exists)
        XCTAssertTrue(app.staticTexts["@texport"].exists)
        
        // Инициируем процесс выхода
        app.buttons["logout button"].tap()
        
        // Подтверждаем действие выхода
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
        
        // Ждем некоторое время, чтобы убедиться, что экран авторизации успел загрузиться
        sleep(5)

        // Проверяем, что кнопка "Войти" снова видна на экране авторизации
        XCTAssertTrue(app.buttons["Authenticate"].exists, "Кнопка 'Войти' должна быть видна на экране после выхода из профиля")
    }
}

