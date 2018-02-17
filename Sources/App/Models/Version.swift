import Vapor
import FluentPostgreSQL

final class Version: Content {
    let packageId: Package.ID
    let tag: String
    
    init(id: Package.ID, tag: String) {
        self.packageId = id
        self.tag = tag
    }
}
