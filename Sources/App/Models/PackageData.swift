import Vapor

struct PackageData: Public {
    let owner: String
    let name: String
    let urls: [String: String]
    let versions: [String]
    
    static func make(from model: Package, with executor: DatabaseConnectable)throws -> Future<PackageData> {
        return try model.versions(queriedWith: executor).all().map(to: PackageData.self, { (versions)  in
            return PackageData(
                owner: model.owner,
                name: model.name,
                urls: [
                    "https": model.https,
                    "ssh": model.ssh
                ],
                versions: versions.map({ $0.tag })
            )
        })
    }
}
