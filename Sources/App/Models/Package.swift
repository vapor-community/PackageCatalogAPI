import Vapor
import FluentPostgreSQL

final class Package: Content {
    var id: Int?
    
    let owner: String
    let name: String
    let host: String
    let versions: [String]
    let branches: [String]
    let license: String
    
    let stars: Int
    let watchers: Int
    let forks: Int
    
    init(owner: String, name: String, host: String = "github", versions: [String] = [], branches: [String] = [], license: String = "MIT", stars: Int, watchers: Int, forks: Int) {
        self.owner = owner
        self.name = name
        self.host = host
        self.versions = versions
        self.branches = branches
        self.license = license
        self.stars = stars
        self.watchers = watchers
        self.forks = forks
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
    func `public`(with executor: DatabaseConnectable) -> Future<Package> {
        return Future(self)
    }
    
    typealias Public = Package
    
    
}
