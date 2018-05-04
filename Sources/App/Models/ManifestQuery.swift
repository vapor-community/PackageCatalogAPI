import Manifest
import Vapor

final class ManifestQuery: GraphQLQuery {
    typealias Response = ManifestExtractor
    
    var query: String = """
    query ($owner: String!, $repo: String!) {
      repository(owner:$owner, name:$repo) {
        file: object(expression: "master:Package.swift") {
          ... on Blob {
              manifest: text
          }
        }
      }
    }
    """
    
    var variables: [String : String]
    var header: [String : String]
    
    init(owner: String, repo: String, token: String) {
        self.variables = ["owner": owner, "repo": repo]
        self.header = ["Authorization": "Bearer \(token)"]
    }
}

struct ManifestExtractor: Content {
    let manifest: Manifest
    
    enum SubKeys: CodingKey {
        case data
        case repository
        case file
    }
    
    init(from decoder: Decoder)throws {
        let container = try decoder.container(keyedBy: SubKeys.self)
        let data = try container.nestedContainer(keyedBy: SubKeys.self, forKey: .data)
        let repo = try data.nestedContainer(keyedBy: SubKeys.self, forKey: .repository)
        self.manifest = try repo.decode(Manifest.self, forKey: .file)
    }
}
