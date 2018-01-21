//
//  UserKey.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 21.01.18.
//

import FluentProvider

final class UserKey: Model {
    let storage = Storage()
    let public_key: String
    
    struct Properties {
        static let id = "id"
        static let public_key = "public_key"
    }
    
    init(public_key: String) {
        self.public_key = public_key
    }
    
    init(row: Row) throws {
        public_key = try row.get(Properties.public_key)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.public_key, public_key)
        return row
    }
}

extension UserKey: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.public_key)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension UserKey: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(public_key: json.get(Properties.public_key))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.id, id)
        try json.set(Properties.public_key, public_key)
        return json
    }
}

extension UserKey: ResponseRepresentable {}

extension UserKey: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        try node.set(Properties.public_key, public_key)
        return node
    }
}
