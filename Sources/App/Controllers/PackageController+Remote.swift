import FluentPostgreSQL
import Vapor

extension PackageController {
    func createFromGitHub(_ request: Request, _ url: RepoURL)throws -> Future<Package> {
        let remote = "https://api.github.com/repos/"
        
        var components = url.repo.split(separator: "/").map(String.init)
        let (name, owner) = (components.removeLast(), components.removeLast())
        let base = remote + owner + "/" + name
        let urls = (main: base, branches: base + "/branches", tags: base + "/releases")
        
        let client = try request.make(Client.self)
        return flatMap(to: GitHubPackageData.self, client.get(urls.main), client.get(urls.branches), client.get(urls.tags)) { repoResponse, branchesReponse, tagsResponse in
            return map(
                to: GitHubPackageData.self,
                try repoResponse.content.decode(GitHubPackage.self),
                try branchesReponse.content.decode([GitHubBranch].self),
                try tagsResponse.content.decode([GitHubRelease].self)
            ) { base, branches, tags -> GitHubPackageData in
                let storedTags = tags.sorted { first, second in
                    return first.name > second.name
                }
                return GitHubPackageData(repo: base, tags: storedTags, branches: branches)
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
                stars: data.repo.stars,
                watchers: data.repo.watchers,
                forks: data.repo.forks
            )
            return package.save(on: request)
        }
    }
}

struct RepoURL: Content {
    let repo: String
}
