import FluentPostgreSQL
import FluentSQL
import Vapor

extension PackageController {
    func search(_ request: Request)throws -> Future<[Package]> {
        let query = Package.query(on: request)
        
        if let name = try request.query.get(String?.self, at: "name") {
            try query.group(.or) { (query) in
                try query.filter(\.owner ~~ name)
                try query.filter(\.name ~~ name)
                try query.filter(\.description ~~ name)
            }
        }
        
        if let host = try request.query.get(String?.self, at: "host") {
            try query.filter(\.host == host)
        }
        
        if let sort = try request.query.get(String?.self, at: "sort_by"), let direction = try request.query.get(String?.self, at: "direction") {
            let sortProperty: KeyPath<Package, Int>
            switch sort {
            case "stars": sortProperty = \.stars
            case "watchers": sortProperty = \.watchers
            case "forks": sortProperty = \.forks
            default: throw Abort(.badRequest, reason: "Bad 'sort' value. Use one of the following: 'stars', 'watchers', 'forks'")
            }
            
            let sortDirection: QuerySortDirection
            switch direction {
            case "asc": sortDirection = .ascending
            case "ascending": sortDirection = .ascending
            case "desc": sortDirection = .descending
            case "descending": sortDirection = .descending
            default: throw Abort(.badRequest, reason: "Bad 'direction' value. Use one of the following: 'asc', 'ascending', 'desc', 'descending'")
            }
            
            _ = try query.sort(sortProperty, sortDirection)
        }
        
        if let license = try request.query.get(String?.self, at: "license") {
            try query.filter(\.license == license)
        }
        
        if let limit = try request.query.get(Int?.self, at: "limit_to") {
            _ = query.range(0...limit)
        }
        
        return query.all()
    }
}
