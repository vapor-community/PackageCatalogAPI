import FluentPostgreSQL
import Manifest
import Vapor

extension PackageController {
    func createFromGitHub(_ request: Request, _ url: RepoURL)throws -> Future<Package> {
        let remote = "https://api.github.com/repos/"
        let readmeURL: String
        let manifest: String
        
        var components = url.repo.split(separator: "/").map(String.init)
        let (name, owner) = (components.removeLast(), components.removeLast())
        let base = remote + owner + "/" + name
        let urls = (main: base, branches: base + "/branches", tags: base + "/releases")
        manifest = "https://raw.githubusercontent.com/\(owner)/\(name)/master/Package.swift"
        readmeURL = "https://raw.githubusercontent.com/\(owner)/\(name)/master/README.md"
        
        let client = try request.make(Client.self)
        
        let packageProducts = client.get(manifest).map(to: [Product].self, { response in
            guard let body = response.http.body.data else {
                throw Abort(.internalServerError, reason: "No manifest was found in the repsonse body")
            }
            return try Manifest(data: body).products()
        }).catchMap { error in
            if let error = error as? AbortError, error.status == .notFound {
                throw Abort(.badRequest, reason: "Attempted to register a repository that is not an SPM package")
            }
            throw error
        }
        
        let readme = client.get(readmeURL).catchMap { _ in
            return request.makeResponse()
        }.map(to: String?.self) { response in
            guard let data = response.http.body.data else { return nil }
            return String(data: data, encoding: .utf8)
        }.catchMap { error in
            if let error = error as? AbortError, error.status == .notFound {
                return nil
            }
            throw error
        }
        
        return flatMap(to: GitHubPackageData.self, client.get(urls.main), client.get(urls.branches), client.get(urls.tags)) { repoResponse, branchesReponse, tagsResponse in
            return map(
                to: GitHubPackageData.self,
                try repoResponse.content.decode(GitHubPackage.self),
                try branchesReponse.content.decode([GitHubBranch].self),
                try tagsResponse.content.decode([GitHubRelease].self),
                packageProducts,
                readme
            ) { base, branches, tags, products, readme -> GitHubPackageData in
                let storedTags = tags.sorted { first, second in
                    return first.name > second.name
                }
                return GitHubPackageData(readme: readme, manifestProducts: products.map({ $0.name }), repo: base, tags: storedTags, branches: branches)
            }
        }.flatMap(to: Package.self) { data in
            let package = Package(
                owner: data.repo.owner.login,
                name: data.repo.name,
                host: "github",
                description: data.repo.description,
                versions: data.tags.map({ $0.name }),
                branches: data.branches.map({ $0.name }),
                license: data.repo.license.id,
                readme: data.readme,
                stars: data.repo.stars,
                watchers: data.repo.watchers,
                forks: data.repo.forks,
                products: data.manifestProducts
            )
            return package.save(on: request)
        }
    }
}

struct RepoURL: Content {
    let repo: String
}
