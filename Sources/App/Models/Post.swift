//
//  Post.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 30.11.17.
//

import Vapor
import Fluent
import FluentProvider
import Foundation

final class Post: Model {
    let storage = Storage()
    var name: String
    
    var exists: Bool = false
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get("name")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
}

extension Post: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id?.string)
        try json.set("name", name)
        return json
    }
}

extension Post: Timestampable { }
extension Post: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
