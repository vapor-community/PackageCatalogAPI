import Vapor
import FluentPostgreSQL

final class Package: Content, PostgreSQLModel, Migration, Parameter {
    var id: Int?
    
    let host: String
    let owner: String
    
    var name: String
    var description: String?
    var versions: [String]
    var branches: [String]
    var license: String
    
    var stars: Int
    var watchers: Int
    var forks: Int
    
    init(
        owner: String,
        name: String,
        host: String = "github",
        description: String? = nil,
        versions: [String] = [],
        branches: [String] = [],
        license: String = "MIT",
        stars: Int,
        watchers: Int,
        forks: Int
    ) {
        self.owner = owner
        self.name = name
        self.host = host
        self.description = description
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
