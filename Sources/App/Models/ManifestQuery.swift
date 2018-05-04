import Manifest
import Vapor

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
        let file = try repo.nestedContainer(keyedBy: CodingKeys.self, forKey: .file)
        self.manifest = try file.decode(Manifest.self, forKey: .manifest)
    }
}
