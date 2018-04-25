import Vapor
import Fluent

protocol Publicizable {
    associatedtype Public: Content
    
    func `public`(with executor: DatabaseConnectable) -> Future<Public>
}

extension Array: Publicizable where Element: Publicizable {
    typealias Public = [Element.Public]
    
    func `public`(with executor: DatabaseConnectable) -> Future<[Element.Public]> {
        return self.map({ $0.public(with: executor) }).flatten(on: executor)
    }
}

extension Future: Publicizable where T: Publicizable {
    typealias Public = T.Public
    
    func `public`(with executor: DatabaseConnectable) -> Future<T.Public> {
        return self.flatMap(to: T.Public.self, { (this) in
            return this.public(with: executor)
        })
    }
}
