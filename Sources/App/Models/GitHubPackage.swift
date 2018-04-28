import Vapor

struct GitHubPackageData: Content {
    let manifestProducts: [String]
    let repo: GitHubPackage
    let tags: [GitHubRelease]
    let branches: [GitHubBranch]
}

// MARK: /owner/name

struct GitHubPackage: Content {
    let name: String
    let owner: GitHubOwner
    let description: String?
    let stars: Int
    let watchers: Int
    let forks: Int
    let license: GitHubLicense
    
    enum CodingKeys: String, CodingKey {
        case name, owner, description, license
        case stars = "stargazers_count"
        case watchers = "watchers_count"
        case forks = "forks_count"
    }
}

struct GitHubOwner: Content {
    let login: String
}

struct GitHubLicense: Content {
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case id = "spdx_id"
    }
}

// MARK: /owner/name/{branches|tags}

struct GitHubBranch: Content {
    let name: String
}

struct GitHubRelease: Content {
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case name = "tag_name"
    }
}
