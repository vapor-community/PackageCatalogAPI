import Vapor
import FluentPostgreSQL
import Fluent
import Foundation

final class PackageController: RouteCollection {
    func index(_ request: Request)throws -> Future<[PackageData]> {
        return Package.query(on: request).all().flatMap(to: [PackageData].self, { (packages) in
            return try packages.public(with: request)
        })
    }
    
    func create(_ request: Request)throws -> Future<PackageData> {
        let package = try JSONDecoder().decode(Package.self, from: request.http.body)
        return package.flatMap(to: Package.self, { (package) in
            package.save(on: request).transform(to: package)
        }).flatMap(to: PackageData.self, { (package) in
            return try package.public(with: request)
        })
    }
    
    func getByName(_ request: Request)throws -> Future<PackageData> {
        let owner = try request.parameter(String.self)
        let name = try request.parameter(String.self)
        let package = Package.query(on: request).filter(\Package.name == name).filter(\Package.owner == owner)
        
        return package.first().flatMap(to: PackageData.self, { (pack) in
            guard let pack = pack else {
                throw Abort(.notFound)
            }
            return try pack.public(with: request)
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
