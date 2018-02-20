import Vapor

struct PackageData: Content {
    let owner: String
    let name: String
    let urls: [String: String]
    let versions: [String]
}

extension Package: Publicizable {
    typealias Public = PackageData
    
    func `public`(with executor: DatabaseConnectable) -> Future<PackageData> {
        return Future(()).flatMap(to: [Version].self, { _ in
            return try self.versions(queriedWith: executor).all()
        }).map(to: PackageData.self, { (versions) in
            let versionTags = versions.map({ $0.tag })
            let urls = ["https": self.https, "ssh": self.ssh]
            
            return PackageData(owner: self.owner, name: self.name, urls: urls, versions: versionTags)
        })
    }
}
