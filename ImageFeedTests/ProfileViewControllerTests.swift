import XCTest
@testable import ImageFeed

class ProfileViewControllerTests: XCTestCase {
    var sut: ProfileViewController!
    var mockNotificationCenter: MockNotificationCenter!
    
    override func setUp() {
        super.setUp()
        sut = ProfileViewController()
        mockNotificationCenter = MockNotificationCenter()
        sut.notificationCenter = mockNotificationCenter
        sut.loadViewIfNeeded()
    }
    
    override func tearDown() {
        sut = nil
        mockNotificationCenter = nil
        super.tearDown()
    }
    
    func testUpdateProfileData_ReceivesNotification_UpdatesLabels() {
        let profileData = ProfileUIData(username: "username123", name: "New Name", loginName: "New Login", bio: "New Bio")
        let userInfo = ["profileData": profileData]
        let notification = Notification(name: .didFetchProfileData, object: nil, userInfo: userInfo)
        
        sut.updateProfileData(notification)
        
        XCTAssertEqual(sut.nameLabel.text, "New Name")
        XCTAssertEqual(sut.usernameLabel.text, "New Login")
        XCTAssertEqual(sut.descriptionLabel.text, "New Bio")
    }
    
    func testUpdateAvatarUserUI_ReceivesNotification_LoadsImage() {
        let urlString = "http://example.com/avatar.jpg"
        let userInfo = ["avatarURL": urlString]
        let notification = Notification(name: .didFetchProfileData, object: nil, userInfo: userInfo)
        
        sut.updateAvatarUserUI(notification)
        
        // Проверяем, что URL был правильно сохранен
        XCTAssertEqual(sut.lastImageURLUsedForLoading?.absoluteString, urlString)
    }
}

class MockNotificationCenter: NotificationCenter {
    var observers = [Any]()
    
    override func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        observers.append(observer)
    }
    
    override func removeObserver(_ observer: Any) {
        if let index = observers.firstIndex(where: { $0 as AnyObject === observer as AnyObject }) {
            observers.remove(at: index)
        }
    }
}
