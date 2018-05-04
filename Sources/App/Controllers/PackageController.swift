import Authentication
import Vapor

final class PackageController: RouteCollection {
    func boot(router: Router) throws {
        let packages = router.grouped("packages")
        
        packages.get("search", use: search)
        packages.get(String.parameter, String.parameter, use: get)
        packages.get(String.parameter, String.parameter, "readme", use: readme)
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
    
    func search(_ request: Request)throws -> Future<SearchResult> {
        guard let token = request.http.headers.bearerAuthorization else {
            throw Abort(
                .unauthorized,
                reason: "GitHub requires an access token with the proper scopes to use the GraphQL API: https://developer.github.com/v4/guides/forming-calls/#authenticating-with-graphql. Add the token to the 'Authorization' header as a bearer token"
            )
        }
        
        let name = try request.query.get(String.self, at: "name")
        return try GitHub.repos(on: request, with: name, accessToken: token.token, searchForks: false).map { search in
            return SearchResult(repositories: search.repos, metadata: search.meta)
        }
    }
    
    func readme(_ request: Request)throws -> Future<Response> {
        guard let token = request.http.headers.bearerAuthorization else {
            throw Abort(
                .unauthorized,
                reason: "GitHub requires an access token with the proper scopes to use the GraphQL API: https://developer.github.com/v4/guides/forming-calls/#authenticating-with-graphql. Add the token to the 'Authorization' header as a bearer token"
            )
        }
        
        let owner = try request.parameters.next(String.self)
        let repo = try request.parameters.next(String.self)
        let query = READMEQuery(owner: owner, repo: repo, token: token.token)
        return try GitHub.send(query: query, on: request).map(to: Response.self) { readme in
            let response = request.makeResponse()
            response.http.body = HTTPBody(data: Data(readme.text.utf8))
            response.http.headers.replaceOrAdd(name: .contentType, value: "text/markdown; charset=UTF-8")
            return response
        }
    }
}

struct SearchResult: Content {
    let repositories: [Repository]
    let metadata: GitHub.MetaInfo
}
