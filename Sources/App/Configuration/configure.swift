import Vapor
import FluentPostgreSQL

/// Called before your application initializes.
///
/// [Learn More →](https://docs.vapor.codes/3.0/getting-started/structure/#configureswift)
public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    try services.register(FluentProvider())
    try services.register(FluentPostgreSQLProvider())
    
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    let psqlConfig = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "calebkleveter")
    var dbConfig = DatabaseConfig()
    
    let database = PostgreSQLDatabase(config: psqlConfig)
    dbConfig.add(database: database, as: .psql)
    services.register(dbConfig)
    
    var migirateConfig = MigrationConfig()
    migirateConfig.add(model: Package.self, database: .psql)
    services.register(migirateConfig)
}
