import Vapor
import FluentPostgreSQL
import Fluent
import Foundation

final class PackageController: RouteCollection {
    func boot(router: Router) throws {
        let packages = router.grouped("packages")
        
        packages.post(Package.self, at: "packages", use: create)
        packages.get(use: index)
        packages.get("search", use: search)
        packages.get(String.parameter, String.parameter, use: getByName)
        packages.patch(PackageUpdateBody.self, at: Package.parameter, use: update)
        packages.delete(String.parameter, String.parameter, use: delete)
        
        packages.post(RepoURL.self, at: "add", "github", use: createFromGitHub)
    }
    
    func create(_ request: Request, _ package: Package)throws -> Future<Package> {
        return package.save(on: request)
    }
    
    func index(_ request: Request)throws -> Future<[Package]> {
        return Package.query(on: request).all()
    }
    
    func getByName(_ request: Request)throws -> Future<Package> {
        let owner = try request.parameters.next(String.self)
        let name = try request.parameters.next(String.self)
        let package = try Package.query(on: request).filter(\Package.name == name).filter(\Package.owner == owner)
        
        return package.first().unwrap(or: Abort(.notFound))
    }
    
    func update(_ request: Request, _ body: PackageUpdateBody)throws -> Future<Package> {
        return try request.parameters.next(Package.self).flatMap(to: Package.self) { package in
            package.name = body.name ?? package.name
            package.description = body.description ?? package.description
            package.versions = body.versions ?? package.versions
            package.branches = body.branches ?? package.branches
            package.license = body.license ?? package.license
            package.stars = body.stars ?? package.stars
            package.watchers = body.watchers ?? package.watchers
            package.forks = body.forks ?? package.forks
            
            return package.update(on: request)
        }
    }
    
    func delete(_ request: Request)throws -> Future<HTTPStatus> {
        let owner = try request.parameters.next(String.self)
        let name = try request.parameters.next(String.self)
        let package = try Package.query(on: request).filter(\Package.name == name).filter(\Package.owner == owner)
        
        return package.first().unwrap(or: Abort(.notFound)).delete(on: request).transform(to: .noContent)
    }
}

struct PackageUpdateBody: Content {
    var name: String?
    var description: String?
    var versions: [String]?
    var branches: [String]?
    var license: String?
    var stars: Int?
    var watchers: Int?
    var forks: Int?
}
