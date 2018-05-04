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
import Vapor

struct QueryRequestBody: Content {
    let query: String
    let variables: [String: String]
}

public enum GitHub {
    public enum Error: Swift.Error, LocalizedError {
        case noPackages
        
        public var errorDescription: String? {
            switch self {
            case .noPackages: return "No packages found."
            }
        }
    }
    
    public struct MetaInfo: Codable {
        let totalRepositoryCount: Int
        let swiftPackageCount: Int
        let rateLimitRemaining: Int
        let rateLimitResetAt: Date
        let queryCost: Int
        
        init(from response: SearchResponse) {
            self.totalRepositoryCount = response.repositoryCount
            self.swiftPackageCount = response.repositories.count
            self.rateLimitRemaining = response.rateLimitRemaining
            self.rateLimitResetAt = response.rateLimitResetAt
            self.queryCost = response.queryCost
        }
    }
    
    static let apiBaseURL = URL(string: "https://api.github.com/graphql")!
    
    static func send<T>(query: T, on request: Request)throws -> Future<T.Response> where T: GraphQLQuery {
        let client = try request.make(Client.self)
        let body: QueryRequestBody = QueryRequestBody(query: query.query, variables: query.variables)
        return client.send(.POST, headers: HTTPHeaders(query.header.map { $0 }), to: apiBaseURL, content: body).flatMap(to: T.Response.self) { response in
            return try response.content.decode(T.Response.self)
        }
    }
    
    public static func repos(on request: Request, with query: String, accessToken: String, searchForks: Bool)throws -> Future<(repos: [Repository], meta: MetaInfo)> {
        let repoQuery = RepoQuery(query: query, accessToken: accessToken, searchForks: searchForks)
        return try send(query: repoQuery, on: request).map(to: (repos: [Repository], meta: MetaInfo).self) { response in
            if let error = response.errors?.first {
                throw error
            }
            
            guard let searchResponse = response.data, searchResponse.repositories.count > 0 else {
                throw GitHub.Error.noPackages
            }
            
            return (searchResponse.repositories, MetaInfo(from: searchResponse))
        }
    }
    
    public static func firstRepo(on request: Request, with query: String, accessToken: String, searchForks: Bool)throws -> Future<(repo: Repository, meta: MetaInfo)> {
        var searchForks = searchForks
        if query.contains("/") {
            searchForks = true
        }
        return try repos(on: request, with: query, accessToken: accessToken, searchForks: searchForks).map(to: (repo: Repository, meta: MetaInfo).self) { response in
            guard let first = response.repos.first else {
                throw GitHub.Error.noPackages
            }
            return (first, response.meta)
        }
    }
}
