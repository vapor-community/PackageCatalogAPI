import Vapor
import FluentPostgreSQL
import Fluent
import Foundation

final class PackageController: RouteCollection {
    func index(_ request: Request)throws -> Future<[Package]> {
        return Package.query(on: request).all()
    }
    
    func create(_ request: Request)throws -> Future<Package> {
        let package = try JSONDecoder().decode(Package.self, from: request.http.body)
        return package.flatMap(to: Package.self, { (package) -> Future<Package> in
            package.save(on: request).transform(to: package)
        })
    }
    
    func getByName(_ request: Request)throws -> Future<Package> {
        let owner = try request.parameter(String.self)
        let name = try request.parameter(String.self)
        let package = Package.query(on: request).filter(\Package.name == name).filter(\Package.owner == owner)
        return package.first().map(to: Package.self, { (pack) -> Package in
            guard let pack = pack else {
                throw Abort(.notFound)
            }
            return pack
        })
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        let owner = try request.parameter(String.self)
        let name = try request.parameter(String.self)
        let package = Package.query(on: request).filter(\Package.name == name).filter(\Package.owner == owner)
        return package.first().flatMap(to: Void.self, { (pack) in
            guard let pack = pack else {
                throw Abort(.notFound)
            }
            return pack.delete(on: request).transform(to: ())
        }).map(to: HTTPStatus.self, { _ in
            return .ok
        })
    }
    
    func boot(router: Router) throws {
        router.get("packages", use: index)
        router.post("packages", use: create)
        router.get("packages", String.parameter, String.parameter, use: getByName)
        router.delete("packages", String.parameter, String.parameter, use: delete)
    }
}
