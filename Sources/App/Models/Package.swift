import Vapor
import FluentPostgreSQL

final class Package: Content {
    var id: Int?
    
    let owner: String
    let name: String
    let host: String
    
    init(owner: String, name: String, host: String = "github") {
        self.owner = owner
        self.name = name
        self.host = host
    }
    
    var ssh: String {
        return "git@\(self.host).com:\(self.owner)/\(self.name)"
    }
    
    var https: String {
        return "https://\(self.host).com/\(self.owner)/\(self.name).git"
    }
}

extension Package: Model {
     typealias Database = PostgreSQLDatabase
    
    static var idKey: WritableKeyPath<Package, Int?> {
        return \.id
    }
}

extension Package: Migration {}

extension Package: Publicizable {
    typealias PublicData = PackageData
}

extension Package {
    func versions(queriedWith executor: DatabaseConnectable)throws -> QueryBuilder<Version> {
        guard let id = self.id else {
            throw Abort(.internalServerError, reason: "The package '\(self.owner)/\(self.name)' has not been saved to the database", identifier: "packageNotSaved")
        }
        return Version.query(on: executor).filter(\.packageId == id).sort(\.tag, .descending)
    }
}
