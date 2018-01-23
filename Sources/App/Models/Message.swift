//
//  Post.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 30.11.17.
//

import FluentProvider
import Foundation

final class Message: Model {
    let storage = Storage()
    let content: String
    let signature: String
    let receiver_id: Identifier?
    let sender_id: String
    let date_sent: Date
    
    struct Properties {
        static let id = "id"
        static let content = "content"
        static let signature = "signature"
        static let receiver_id = "receiver_id"
        static let sender_id = "sender_id"
        static let date_sent = "date_sent"
    }
    
    init(content: String, signature: String, user: User, sender_id: String) {
        self.content = content
        self.signature = signature
        self.receiver_id = user.id
        self.sender_id = sender_id
        self.date_sent = Date()
    }
    
    init(row: Row) throws {
        content = try row.get(Properties.content)
        signature = try row.get(Properties.signature)
        sender_id = try row.get(Properties.sender_id)
        date_sent = try row.get(Properties.date_sent)
        receiver_id = try row.get(User.foreignIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Properties.content, content)
        try row.set(Properties.signature, signature)
        try row.set(Properties.sender_id, sender_id)
        try row.set(Properties.date_sent, date_sent)
        try row.set(User.foreignIdKey, receiver_id)
        return row
    }
}

extension Message: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Properties.content)
            builder.string(Properties.signature)
            builder.string(Properties.sender_id)
            builder.string(Properties.date_sent)
            builder.parent(User.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Message: JSONConvertible {
    convenience init(json: JSON) throws {
        let receiver_id: Identifier = try json.get(Properties.receiver_id)
        guard let user = try User.find(receiver_id) else {
            throw Abort.badRequest
        }
        try self.init(content: json.get(Properties.content), signature: json.get(Properties.signature), user: user, sender_id: json.get(Properties.sender_id))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Properties.id, id)
        try json.set(Properties.content, content)
        try json.set(Properties.signature, signature)
        try json.set(Properties.sender_id, sender_id)
        try json.set(Properties.date_sent, date_sent)
        try json.set(Properties.receiver_id, receiver_id)
        return json
    }
}

extension Message: ResponseRepresentable {}

extension Message {
    var user: Parent<Message, User> {
        return parent(id: receiver_id)
    }
}

extension Message: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node([:], in: context)
        try node.set(Properties.id, id)
        try node.set(Properties.content, content)
        try node.set(Properties.signature, signature)
        try node.set(Properties.sender_id, sender_id)
        try node.set(Properties.date_sent, date_sent)
        return node
    }
}

