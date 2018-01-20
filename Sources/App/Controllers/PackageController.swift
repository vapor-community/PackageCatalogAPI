import Vapor
import FluentPostgreSQL
import Fluent
import Foundation

final class PackageController: RouteCollection {
    func index(_ request: Request)throws -> Future<[Package]> {
        return Package.query(on: request).all()
    }
    
    func create(_ request: Request)throws -> Future<Package> {
        let package = try JSONDecoder().decode(Package.self, from: request.body)
        return package.flatMap(to: Package.self, { (package) -> Future<Package> in
            package.save(on: request).transform(to: package)
        })
    }
    
    func getById(_ request: Request)throws -> Future<Package> {
        let id: Int = try request.parameter()
        let package = Package.find(id, on: request).map(to: Package.self, { (package)throws -> Package in
            guard let package = package else {
                throw Abort(.badRequest)
            }
            return package
        })
        return package
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
    
    func boot(router: Router) throws {
        router.get("packages", use: index)
        router.post("packages", use: create)
        router.get("packages", String.parameter, String.parameter, use: getByName)
//        router.get("packages", Int.parameter, use: getById)
    }
}
