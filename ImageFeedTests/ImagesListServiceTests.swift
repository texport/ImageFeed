@testable import ImageFeed
import XCTest

final class ImagesListServiceIntegrationTests: XCTestCase {
    var service: ImagesListService!
    var expectation: XCTestExpectation!

    override func setUp() {
        super.setUp()
        service = ImagesListService()
        expectation = XCTestExpectation(description: "Service fetches and parses data correctly")
    }

    func testFetchPhotosNextPage() {
        service.fetchPhotosNextPage()

        // Ожидаем уведомления о завершении загрузки
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: ImagesListService.didChangeNotification, object: nil)

        // Устанавливаем таймаут для асинхронного теста
        wait(for: [expectation], timeout: 10.0)
    }

    @objc func handleNotification(_ notification: Notification) {
        // Проверяем, что количество фотографий равно 10
        XCTAssertEqual(self.service.photos.count, 10, "Should load exactly 10 photos per page")
        self.expectation.fulfill()

        // Удаляем наблюдателя после выполнения теста
        NotificationCenter.default.removeObserver(self, name: ImagesListService.didChangeNotification, object: nil)
    }

    override func tearDown() {
        service = nil
        expectation = nil
        super.tearDown()
    }
}
