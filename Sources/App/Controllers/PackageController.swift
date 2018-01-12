import Vapor
import Foundation

final class PackageController: RouteCollection {
    func index(_ request: Request)throws -> Future<[Package]> {
        return Package.query(on: request).all()
    }
    
    func create(_ request: Request)throws -> Future<Package> {
        let package = try JSONDecoder().decode(Package.self, from: request.body)
        return package.save(on: request).transform(to: package)
    }
    
    func boot(router: Router) throws {
        router.get("packages", use: index)
        router.post("packages", use: create)
    }
}
