import FluentPostgreSQL

extension Package: Model {
    static var idKey: IDKey {
        return \.id
    }
    
    typealias Database = PostgreSQLDatabase
    typealias ID = Int
}
