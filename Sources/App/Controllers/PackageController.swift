import Vapor
import FluentPostgreSQL
import Fluent
import Foundation

final class PackageController: RouteCollection {
    func index(_ request: Request)throws -> Future<[PackageData]> {
        return Package.query(on: request).all().public(with: request)
    }
    
    func create(_ request: Request)throws -> Future<PackageData> {
        let package = try JSONDecoder().decode(Package.self, from: request.http.body)
        return package.save(on: request).public(with: request)
    }
    
    func getByName(_ request: Request)throws -> Future<PackageData> {
        let owner = try request.parameter(String.self)
        let name = try request.parameter(String.self)
        let package = Package.query(on: request).filter(\Package.name == name).filter(\Package.owner == owner)
        
        return package.first().unwrap(or: Abort(.notFound)).public(with: request)
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        let owner = try request.parameter(String.self)
        let name = try request.parameter(String.self)
        let package = Package.query(on: request).filter(\Package.name == name).filter(\Package.owner == owner)
        
        return package.first().unwrap(or: Abort(.notFound)).delete(on: request).transform(to: .ok)
    }
    
    func boot(router: Router) throws {
        router.get("packages", use: index)
        router.post("packages", use: create)
        router.get("packages", String.parameter, String.parameter, use: getByName)
        router.delete("packages", String.parameter, String.parameter, use: delete)
    }
}
