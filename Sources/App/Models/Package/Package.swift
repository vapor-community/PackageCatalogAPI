import Vapor

final class Package: Content {
    var id: Int?
    let owner: String
    let name: String
    let gitUrl: String
    
    init(owner: String, name: String, gitUrl: String) {
        self.owner = owner
        self.name = name
        self.gitUrl = gitUrl
    }
}
