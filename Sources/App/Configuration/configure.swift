import Vapor
import MySQL
import FluentMySQL

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    try services.register(FluentProvider())
    try services.register(FluentMySQLProvider())
    
    var dbConfig = DatabaseConfig()
    let database = MySQLDatabase(hostname: "localhost", user: "root", password: nil, database: "package_catalog")
    dbConfig.add(database: database, as: .mysql)
    services.register(dbConfig)
    
    var migirateConfig = MigrationConfig()
    migirateConfig.add(model: Package.self, database: .mysql)
    services.register(migirateConfig)
}
