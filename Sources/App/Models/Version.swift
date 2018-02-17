import Vapor
import FluentPostgreSQL

final class Version: Content {
    var id: Int?
    
    let packageId: Package.ID
    let tag: String
    
    init(id: Package.ID, tag: String) {
        self.packageId = id
        self.tag = tag
    }
}

extension Version: Model {
    typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Version, Int?> {
        return \.id
    }
}

extension Version: Migration {}
