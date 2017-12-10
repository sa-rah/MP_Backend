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
        userGroup.post(handler: createUser)
        userGroup.delete(User.parameter, handler: deleteUser)
        userGroup.delete(User.parameter, "messages/deleteAll", handler: deleteUsersMessages)
        userGroup.get(User.parameter, handler: getUser)
        userGroup.get(User.parameter, "messages", handler: getUsersMessages)
    }
    
    func createUser(_ req: Request) throws -> ResponseRepresentable {
        guard let public_id = req.data["public_id"]?.string else {
            throw Abort.badRequest
        }
        let user = try User(public_id: public_id)
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
    
    func deleteUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        try user.delete()
        return user
    }
    
    func getUsersMessages(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return try user.messages.all().makeJSON()
    }
    
    func deleteUsersMessages(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        let messages = try Message.makeQuery().filter("user__id" == user.id).all()
        
        for msg in messages {
            try msg.delete()
        }
        
        return "Successfully deleted messages"
    }
    
}
