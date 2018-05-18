import Vapor

final class READMEQuery: GraphQLQuery {
    typealias Response = README
    
    var query: String = """
    query ($owner: String!, $repo: String!) {
        repository(owner:$owner, name:$repo) {
        readme: object(expression: "master:README.md") {
          ... on Blob {
              text
          }
        }
      }
    }
    """
    
    var variables: [String : Any]
    var header: [String : String]
    
    init(owner: String, repo: String, token: String) {
        self.variables = ["owner": owner, "repo": repo]
        self.header = ["Authorization": "Bearer \(token)"]
    }
}

struct README: Content {
    public static var defaultMediaType: MediaType = .init(type: "text", subType: "markdown", parameters: ["charset": "UTF-8"])
    
    let text: String
    
    enum SubKeys: CodingKey {
        case data
        case repository
        case readme
    }
    
    init(from decoder: Decoder)throws {
        let container = try decoder.container(keyedBy: SubKeys.self)
        let data = try container.nestedContainer(keyedBy: SubKeys.self, forKey: .data)
        let repo = try data.nestedContainer(keyedBy: SubKeys.self, forKey: .repository)
        let readme = try repo.nestedContainer(keyedBy: CodingKeys.self, forKey: .readme)
        self.text = try readme.decode(String.self, forKey: .text)
    }
}
