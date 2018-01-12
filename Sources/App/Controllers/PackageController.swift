import Vapor
import Foundation

final class PackageController: RouteCollection {
    func index(_ request: Request)throws -> Future<[Package]> {
        return Package.query(on: request).all()
    }
    
    func boot(router: Router) throws {
        router.get("packages", use: index)
    }
}
