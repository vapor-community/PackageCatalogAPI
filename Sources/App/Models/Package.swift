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
    var readme: String?
    
    var stars: Int
    var watchers: Int
    var forks: Int
    
    var products: [String]
    
    init(
        owner: String,
        name: String,
        host: String = "github",
        description: String? = nil,
        versions: [String] = [],
        branches: [String] = [],
        license: String = "MIT",
        readme: String? = nil,
        stars: Int,
        watchers: Int,
        forks: Int,
        products: [String] = []
    ) {
        self.owner = owner
        self.name = name
        self.host = host
        self.description = description
        self.versions = versions
        self.branches = branches
        self.license = license
        self.readme = readme
        self.stars = stars
        self.watchers = watchers
        self.forks = forks
        self.products = products
    }
    
    var ssh: String {
        return "git@\(self.host).com:\(self.owner)/\(self.name)"
    }
    
    var https: String {
        return "https://\(self.host).com/\(self.owner)/\(self.name).git"
    }
}
