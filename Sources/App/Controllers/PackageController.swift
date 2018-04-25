import Vapor
import FluentPostgreSQL
import Fluent
import Foundation

final class PackageController: RouteCollection {
    func index(_ request: Request)throws -> Future<[Package]> {
        return Package.query(on: request).all()
    }
    
    func create(_ request: Request, _ package: Package)throws -> Future<Package> {
        return package.save(on: request)
    }
    
    func getByName(_ request: Request)throws -> Future<Package> {
        let owner = try request.parameters.next(String.self)
        let name = try request.parameters.next(String.self)
        let package = try Package.query(on: request).filter(\Package.name == name).filter(\Package.owner == owner)
        
        return package.first().unwrap(or: Abort(.notFound))
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        let owner = try request.parameters.next(String.self)
        let name = try request.parameters.next(String.self)
        let package = try Package.query(on: request).filter(\Package.name == name).filter(\Package.owner == owner)
        
        return package.first().unwrap(or: Abort(.notFound)).delete(on: request).transform(to: .ok)
    }
    
    func boot(router: Router) throws {
        router.get("packages", use: index)
        router.post(Package.self, at: "packages", use: create)
        router.get("packages", String.parameter, String.parameter, use: getByName)
        router.delete("packages", String.parameter, String.parameter, use: delete)
    }
}
