//
//  Post.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 30.11.17.
//

import FluentProvider

final class Message: Model {
    let storage = Storage()
    let content: String
    
    struct Properties {
        static let id = "id"
        static let content = "content"
    }
    
    init(content: String) {
        self.content = content
    }
    
    init(row: Row) throws {
        content = try row.get(Properties.content)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.content, content)
        return row
    }
}

extension Message: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.content)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Message: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(content: json.get(Properties.content))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.id, id)
        try json.set(Properties.content, content)
        return json
    }
}

extension Message: ResponseRepresentable {}

extension Message: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        try node.set(Properties.content, content)
        return node
    }
}

