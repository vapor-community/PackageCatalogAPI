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
import Core

protocol GraphQLQuery {
    associatedtype Response: Decodable
    var query: String { get }
    var variables: [String: Any] { get }
    var header: [String: String] { get }
}

struct RepoQuery: GraphQLQuery {
    typealias Response = RepoResponse
    let query = """
    query ($query: String!, $limit: Int!) {
      search(query: $query, type: REPOSITORY, first: $limit) {
        repositoryCount
        repositories: edges {
          node {
            ... on Repository {
              nameWithOwner
              description
              sshUrl
              url
              isFork
              parent {
                nameWithOwner
              }
              isPrivate
              pushedAt
              licenseInfo {
                name
              }
              openIssues: issues(first: 0, states: OPEN) {
                totalCount
              }
              stargazers(first: 0) {
                totalCount
              }
              packageManifest: object(expression: "master:Package.swift") {
                ... on Blob {
                  text
                }
              }
            }
          }
        }
      }
      rateLimit {
        cost
        remaining
        resetAt
      }
    }
    """
    let variables: [String: Any]
    let header: [String: String]
    init(name: String, limit: Int = 100, accessToken: String, searchOptions: [String: String]) {
        var queryString = "\(name) language:Swift"
        for (key, value) in searchOptions {
            queryString += " \(key):\(value)"
        }
        
        self.variables = ["query": queryString, "limit": limit]
        self.header = ["Authorization": "Bearer \(accessToken)"]
    }
}

public struct RepoResponse: Decodable {
    public let data: SearchResponse?
    public let errors: [ErrorResponse]?
}

public struct SearchResponse: Decodable {
    public let repositoryCount: Int
    public let repositories: [Repository]
    public let queryCost: Int
    public let rateLimitRemaining: Int
    public let rateLimitResetAt: Date
    
    private enum SearchKeys: String, CodingKey {
        case search
        case rateLimit
    }
    
    private enum CodingKeys: String, CodingKey {
        case repositoryCount
        case repositories
    }
    
    private enum RateLimitKeys: String, CodingKey {
        case cost
        case remaining
        case resetAt
    }
    
    public init(from decoder: Decoder) throws {
        let searchContainer = try decoder.container(keyedBy: SearchKeys.self)
        let container = try searchContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .search)
        self.repositoryCount = try container.decode(Int.self, forKey: .repositoryCount)
        let repositories = try container.decode([Repository].self, forKey: .repositories)
        self.repositories = repositories.filter { $0.hasPackageManifest }
        let rateLimitContainer = try searchContainer.nestedContainer(keyedBy: RateLimitKeys.self, forKey: .rateLimit)
        self.queryCost = try rateLimitContainer.decode(Int.self, forKey: .cost)
        self.rateLimitRemaining = try rateLimitContainer.decode(Int.self, forKey: .remaining)
        self.rateLimitResetAt = try rateLimitContainer.decode(Date.self, forKey: .resetAt)
    }
}

public struct ErrorResponse: Decodable, Error, LocalizedError, Debuggable {
    let message: String
    
    public var identifier: String { return "githubAPIError" }
    public var reason: String { return self.message }
    
    public var errorDescription: String? {
        return "GitHub API Error: \(message)"
    }
}
