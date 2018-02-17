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
    
    var http: String {
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
