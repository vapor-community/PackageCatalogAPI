import FluentMySQL
import Vapor

extension Request: DatabaseConnectable {}

extension DatabaseIdentifier {
    static var mysql: DatabaseIdentifier<MySQLDatabase> {
        return .init("mysql")
    }
}

