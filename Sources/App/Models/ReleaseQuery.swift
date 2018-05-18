import Vapor

final class ReleasesQuery: GraphQLQuery {
    typealias Response = Releases
    
    var query: String = """
    query ($owner: String!, $repo: String!) {
        repository(owner:$owner, name:$repo) {
        refs(first: 100, refPrefix: "refs/tags/", orderBy: {field: ALPHABETICAL, direction: DESC}) {
          nodes {
            name
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

struct Releases: Content {    
    let releases: [String]
    
    enum SubKeys: CodingKey {
        case data
        case repository
        case refs
        case nodes
        case tag
        case name
    }
    
    init(from decoder: Decoder)throws {
        var tags: [String] = []
        
        let container = try decoder.container(keyedBy: SubKeys.self)
        let data = try container.nestedContainer(keyedBy: SubKeys.self, forKey: .data)
        let respository = try data.nestedContainer(keyedBy: SubKeys.self, forKey: .repository)
        let refs = try respository.nestedContainer(keyedBy: SubKeys.self, forKey: .refs)
        var nodes = try refs.nestedUnkeyedContainer(forKey: .nodes)
        
        while !nodes.isAtEnd {
            let release = try nodes.nestedContainer(keyedBy: SubKeys.self)
            try tags.append(release.decode(String.self, forKey: .name))
        }
        
        self.releases = tags
    }
}

extension Array where Element == String {
    public static var defaultContentType: MediaType {
        return .json
    }
}
