//
//  User.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 08.12.17.
//

import FluentProvider
import AuthProvider

final class User: Model {
    let storage = Storage()
    
    struct Properties {
        static let id = "id"
    }
    
    init() {}
    
    init(row: Row) throws {}
    
    func makeRow() throws -> Row {
        var row = Row()
        return row
    }
}

extension User: TokenAuthenticatable {
    // the token model that should be queried
    // to authenticate this user
    public typealias TokenType = Token
}

extension User: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init()
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.id, id)
        return json
    }
}

extension User: ResponseRepresentable {}

extension User {
    var messages: Children<User, Message> {
        return children()
    }
    var token: Children<User, Token> {
        return children()
    }
}

extension User: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        return node
    }
}
