import FluentMySQL

extension Package: Model {
    static var database = DatabaseIdentifier<MySQLDatabase>.mysql
    static var idKey: IDKey {
        return \.id
    }
    
    typealias Database = MySQLDatabase
    typealias ID = Int
}
