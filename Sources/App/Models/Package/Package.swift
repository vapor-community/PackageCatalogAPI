import FluentMySQL

final class Package {
    let author: String
    let name: String
    let gitUrl: String
    
    init(author: String, name: String, gitUrl: String) {
        self.author = author
        self.name = name
        self.gitUrl = gitUrl
    }
}
