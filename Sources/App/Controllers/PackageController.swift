import Vapor

final class PackageController: RouteCollection {
    func boot(router: Router) throws {
        let packages = router.grouped("packages")
        
        packages.get(String.parameter, String.parameter, use: get)
    }
    
    func get(_ request: Request)throws -> Future<Response> {
        let owner = try request.parameters.next(String.self)
        let repo = try request.parameters.next(String.self)
        let client = try request.make(Client.self)
        
        let manifest = client.get("https://raw.githubusercontent.com/\(owner)/\(repo)/master/Package.swift")
        return manifest.flatMap(to: Response.self) { response in
            let status = response.http.status
            guard status.code / 100 == 2 else {
                if status.code == 404 { throw Abort(.notFound, reason: "No package found with name '\(owner)/\(repo)'") }
                throw Abort(HTTPStatus.custom(code: status.code, reasonPhrase: status.reasonPhrase))
            }
            return client.get("https://api.github.com/repos/\(owner)/\(repo)")
        }.map(to: Response.self) { response in
            guard let data = response.http.body.data else {
                throw Abort(.notFound, reason: "No package found with name '\(owner)/\(repo)'")
            }
            let response = request.makeResponse()
            response.http.body = HTTPBody(data: data)
            response.http.headers.replaceOrAdd(name: .contentType, value: "application/json")
            return response
        }
    }
}
