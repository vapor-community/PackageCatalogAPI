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
    try services.provider(FluentProvider())
    services.instance(FluentMySQLConfig())
    
    var dbConfig = DatabaseConfig()
    let database = MySQLDatabase(hostname: "localhost", user: "root", password: nil, database: "package_catalog")
    dbConfig.add(database: database, as: .mysql)
    services.instance(dbConfig)
    
    var migirateConfig = MigrationConfig()
    // Add models here:
    // migrationConfig.add(model: MyModel.self, database: .mysql)
    migirateConfig.add(model: Package.self, database: .mysql)
    services.instance(migirateConfig)
    
    
    // configure your application here
    let mysql = MySQLProvider(hostname: "127.0.0.1", user: "root", password: nil, database: "package_catalog")
    try mysql.register(&services)
}

extension DatabaseIdentifier {
    static var mysql: DatabaseIdentifier<MySQLDatabase> {
        return .init("mysql")
    }
}
