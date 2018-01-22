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
    let public_id: String
    
    struct Properties {
        static let id = "id"
        static let public_key = "public_key"
        static let public_id = "public_id"
    }
    
    init(public_key: String, public_id: String) {
        self.public_key = public_key
        self.public_id = public_id
    }
    
    init(row: Row) throws {
        public_key = try row.get(Properties.public_key)
        public_id = try row.get(Properties.public_id)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.public_key, public_key)
        try row.set(Properties.public_id, public_id)
        return row
    }
}

extension UserKey: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.public_key)
            builder.string(Properties.public_id)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension UserKey: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(public_key: json.get(Properties.public_key), public_id: json.get(Properties.public_id))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.id, id)
        try json.set(Properties.public_key, public_key)
        try json.set(Properties.public_id, public_id)
        return json
    }
}

extension UserKey: ResponseRepresentable {}

extension UserKey: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        try node.set(Properties.public_key, public_key)
        try node.set(Properties.public_id, public_id)
        return node
    }
}
