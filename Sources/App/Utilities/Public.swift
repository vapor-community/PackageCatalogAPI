import Vapor

protocol Public: Content {
    associatedtype Data: Encodable
    
    static func make(from model: Data, with executor: DatabaseConnectable)throws -> Future<Self>
}

protocol Publicizable {
    associatedtype PublicData: Public
    
    func `public`(with executor: DatabaseConnectable)throws -> Future<PublicData>
}

extension Publicizable where Self.PublicData.Data == Self {
    func `public`(with executor: DatabaseConnectable)throws -> Future<PublicData> {
        return try PublicData.make(from: self, with: executor)
    }
}

extension Array: Public where Element: Public {
    typealias Data = [Element]
    
    static func make(from model: [Element], with executor: DatabaseConnectable) throws -> Future<Array<Element>> {
        return Future(model)
    }
}

extension Array: Publicizable where Element: Publicizable {
    typealias PublicData = [Element.PublicData]
    
    func `public`(with executor: DatabaseConnectable) throws -> Future<[Element.PublicData]> {
        return try self.map({ try $0.public(with: executor) }).flatten()
    }
}
