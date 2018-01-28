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
    var device_info: String
    var push_token: String
    var public_key: String
    
    struct Properties {
        static let id = "id"
        static let device_info = "device_info"
        static let push_token = "push_token"
        static let public_key = "public_key"
    }
    
    init(device_info: String, push_token: String, public_key: String) {
        self.device_info = device_info
        self.push_token = push_token
        self.public_key = public_key
    }
    
    init(row: Row) throws {
        device_info = try row.get(Properties.device_info)
        push_token = try row.get(Properties.push_token)
        public_key = try row.get(Properties.public_key)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.device_info, device_info)
        try row.set(Properties.push_token, push_token)
        try row.set(Properties.public_key, public_key)
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
            builder.string(Properties.device_info)
            builder.string(Properties.push_token)
            builder.string(Properties.public_key)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: JSONConvertible {
    convenience init(json: JSON) throws {
         try self.init(device_info: json.get(Properties.device_info), push_token: json.get(Properties.push_token), public_key: json.get(Properties.public_key))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.id, id)
        try json.set(Properties.device_info, device_info)
        try json.set(Properties.push_token, push_token)
        try json.set(Properties.public_key, public_key)
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
        try node.set(Properties.device_info, device_info)
        try node.set(Properties.push_token, push_token)
        try node.set(Properties.public_key, public_key)
        return node
    }
}
