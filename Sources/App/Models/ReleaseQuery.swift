import Vapor

final class ReleasesQuery: GraphQLQuery {
    typealias Response = Releases
    
    var query: String = """
    query ($owner: String!, $repo: String!) {
        repository(owner:$owner, name:$repo) {
        releases(first: 100, orderBy: {field: NAME, direction: DESC}) {
          nodes {
            tag {
              name
            }
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

struct Releases: Content {
    let releases: [String]
    
    enum SubKeys: CodingKey {
        case data
        case repository
        case releases
        case nodes
        case tag
        case name
    }
    
    init(from decoder: Decoder)throws {
        var tags: [String] = []
        
        let container = try decoder.container(keyedBy: SubKeys.self)
        let data = try container.nestedContainer(keyedBy: SubKeys.self, forKey: .data)
        let respository = try data.nestedContainer(keyedBy: SubKeys.self, forKey: .repository)
        let releases = try respository.nestedContainer(keyedBy: SubKeys.self, forKey: .releases)
        var nodes = try releases.nestedUnkeyedContainer(forKey: .nodes)
        
        while !nodes.isAtEnd {
            let release = try nodes.nestedContainer(keyedBy: SubKeys.self)
            let tag = try release.nestedContainer(keyedBy: SubKeys.self, forKey: .tag)
            try tags.append(tag.decode(String.self, forKey: .name))
        }
        
        self.releases = tags
    }
}
