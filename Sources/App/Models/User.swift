//
//  User.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 08.12.17.
//

import FluentProvider

final class User: Model {
    let storage = Storage()
    let public_id: String
    
    struct Properties {
        static let id = "id"
        static let public_id = "public_id"
    }
    
    init(public_id: String) {
        self.public_id = public_id
    }
    
    init(row: Row) throws {
        public_id = try row.get(Properties.public_id)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.public_id, public_id)
        return row
    }
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.public_id)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(public_id: json.get(Properties.public_id))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.id, id)
        try json.set(Properties.public_id, public_id)
        return json
    }
}

extension User: ResponseRepresentable {}

extension User {
    var messages: Children<User, Message> {
        return children()
    }
}

extension User: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        try node.set(Properties.public_id, public_id)
        return node
    }
}
