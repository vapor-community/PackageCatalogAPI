// A fair amount of code is copied from the [kiliankoe/apodidae](https://github.com/kiliankoe/apodidae) repository on GitHub. Many thanks to Kilian for putting all his hard owrk under the MIT license and making this package possible.
//
// MIT License
//
// Copyright (c) 2017 Kilian Koeltzsch
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

public typealias Tag = String
public typealias Head = String

public struct Repository: Decodable {
    public let nameWithOwner: String
    public let description: String?
    public let url: URL
    public let isFork: Bool
    public let parent: String?
    public let isPrivate: Bool
    public let pushedAt: Date
    public let license: String?
    public let openIssues: Int
    public let stargazers: Int
    public var tags: [Tag] = []
    public var heads: [Head] = []
    public let packageManifest: String?
    
    public var hasPackageManifest: Bool {
        return self.packageManifest != nil
    }
    
    public var owner: String {
        return nameWithOwner.components(separatedBy: "/").first ?? ""
    }
    
    public var name: String {
        return nameWithOwner.components(separatedBy: "/").last ?? ""
    }
    
    private enum CodingKeys: String, CodingKey {
        case nameWithOwner
        case description
        case url
        case isFork
        case parent
        case isPrivate
        case pushedAt
        case license
        case openIssues
        case stargazers
        case packageManifest
    }
    
    private enum NodeKeys: String, CodingKey {
        case node
    }
    
    private enum EdgesKeys: String, CodingKey {
        case edges
    }
    
    private enum TotalCountContainer: String, CodingKey {
        case totalCount
    }
    
    private enum PackageManifestContainer: String, CodingKey {
        case text
    }
    
    private enum ParentContainer: String, CodingKey {
        case nameWithOwner
    }
    
    public init(from decoder: Decoder) throws {
        let nodeContainer = try decoder.container(keyedBy: NodeKeys.self)
        let container = try nodeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .node)
        self.nameWithOwner = try container.decode(String.self, forKey: .nameWithOwner)
        self.description = try container.decode(String?.self, forKey: .description)
        self.url = try container.decode(URL.self, forKey: .url)
        self.isFork = try container.decode(Bool.self, forKey: .isFork)
        
        let parentContainer = try? container.nestedContainer(keyedBy: ParentContainer.self, forKey: .parent)
        self.parent = try parentContainer?.decode(String?.self, forKey: .nameWithOwner)
        
        self.isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        self.pushedAt = try container.decode(Date.self, forKey: .pushedAt)
        self.license = try container.decode(String?.self, forKey: .license)
        
        let openIssuesContainer = try container.nestedContainer(keyedBy: TotalCountContainer.self, forKey: .openIssues)
        self.openIssues = try openIssuesContainer.decode(Int.self, forKey: .totalCount)
        
        let stargazersContainer = try container.nestedContainer(keyedBy: TotalCountContainer.self, forKey: .stargazers)
        self.stargazers = try stargazersContainer.decode(Int.self, forKey: .totalCount)
        
        let packageManifestContainer = try? container.nestedContainer(keyedBy: PackageManifestContainer.self, forKey: .packageManifest)
        if let packageManifestContainer = packageManifestContainer {
            self.packageManifest = try packageManifestContainer.decode(String.self, forKey: .text)
        } else {
            self.packageManifest = nil
        }
    }
}
