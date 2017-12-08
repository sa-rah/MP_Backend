//
//  UserController.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 08.12.17.
//

import Vapor
import FluentProvider

final class UserController {
    
    func addRoutes(to drop: Droplet) {
        let userGroup = drop.grouped("api", "users")
        userGroup.get(handler: allUsers)
        userGroup.post("create", handler: createUser)
        userGroup.get(User.parameter, handler: getUser)
    }
    
    func createUser(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.data["public_id"]?.string else {
            throw Abort.badRequest
        }
        let user = try User(public_id: json)
        try user.save()
        return user
    }
    
    func allUsers(_ req: Request) throws -> ResponseRepresentable {
        let users = try User.all()
        return try users.makeJSON()
    }
    
    func getUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return user
    }
    
}
