//
//  Token.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 24.01.18.
//

import Foundation
import FluentProvider

final class Token: Model {
    let storage = Storage()
    let token: String
    let user_id: Identifier?
    
    struct Properties {
        static let id = "id"
        static let token = "token"
        static let user_id = "user_id"
    }
    
    init(user: User) {
        self.token = UUID().uuidString
        self.user_id = user.id
    }
    
    init(row: Row) throws {
        token = try row.get(Properties.token)
        user_id = try row.get(User.foreignIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.token, token)
        try row.set(User.foreignIdKey, user_id)
        return row
    }
}

extension Token {
    var user: Parent<Token, User> {
        return parent(id: user_id)
    }
}

extension Token: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.token)
            builder.parent(User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Token: JSONConvertible {
    convenience init(json: JSON) throws {
        let user_id: Identifier = try json.get(Properties.user_id)
        guard let user = try User.find(user_id) else {
            throw Abort.badRequest
        }
        try self.init(user: user)
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.id, id)
        try json.set(Properties.token, token)
        try json.set(Properties.user_id, user_id)
        return json
    }
}

extension Token: ResponseRepresentable {}

extension Token: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        try node.set(Properties.token, token)
        return node
    }
}
