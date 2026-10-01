import XCTest
import RealmSwift
@testable import Instagram

final class LocalStorageTests: XCTestCase {
    private var previous: Realm.Configuration!
    private var directory: URL!
    override func setUpWithError() throws {
        previous = Realm.Configuration.defaultConfiguration
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        Realm.Configuration.defaultConfiguration = Realm.Configuration(fileURL: directory.appendingPathComponent("test.realm"))
    }
    override func tearDownWithError() throws {
        Realm.Configuration.defaultConfiguration = previous
        try FileManager.default.removeItem(at: directory)
    }
    func testArtworkImageAndFavoriteSurviveReopen() throws {
        var id = ""
        try autoreleasepool {
            let realm = try Realm(); let artwork = LocalArtwork(); artwork.caption = "离线作品"
            artwork.imageData = Data([1, 2, 3, 4]); artwork.favorite = true; id = artwork.id
            try realm.write { realm.add(artwork) }
        }
        try autoreleasepool {
            let realm = try Realm(); let artwork = try XCTUnwrap(realm.object(ofType: LocalArtwork.self, forPrimaryKey: id))
            XCTAssertEqual(artwork.caption, "离线作品"); XCTAssertEqual(artwork.imageData, Data([1, 2, 3, 4])); XCTAssertTrue(artwork.favorite)
            try realm.write { realm.delete(artwork) }
        }
        XCTAssertNil(try Realm().object(ofType: LocalArtwork.self, forPrimaryKey: id))
    }
    func testNewWorksHaveUniqueIdentifiers() throws {
        let realm = try Realm(); let first = LocalArtwork(); let second = LocalArtwork()
        try realm.write { realm.add([first, second]) }
        XCTAssertEqual(realm.objects(LocalArtwork.self).count, 2)
        XCTAssertNotEqual(first.id, second.id)
    }
}
