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
    
    var variables: [String : String]
    var header: [String : String]
    
    init(owner: String, repo: String, token: String) {
        self.variables = ["owner": owner, "repo": repo]
        self.header = ["Authorization": "Bearer \(token)"]
    }
}

struct README: Codable {
    let text: String
    
    enum SubKeys: CodingKey {
        case data
        case repository
        case readme
    }
    
    init(from decoder: Decoder)throws {
        let data = try decoder.container(keyedBy: SubKeys.self)
        let repo = try data.nestedContainer(keyedBy: SubKeys.self, forKey: .repository)
        let readme = try repo.nestedContainer(keyedBy: CodingKeys.self, forKey: .readme)
        self.text = try readme.decode(String.self, forKey: .text)
    }
}
