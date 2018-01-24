//
//  UserController.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 08.12.17.
//

import Vapor
import FluentProvider
import HTTP
import JSON

final class UserController {
    
    func addRoutes(to auth: RouteBuilder, drop: Droplet) {
        drop.post("api/users", handler: createUser)
        let userGroup = auth.grouped("api", "users")
       // userGroup.get(handler: allUsers)
        userGroup.delete(User.parameter, handler: deleteUser)
        userGroup.delete(User.parameter, "messages/deleteAll", handler: deleteUsersMessages)
        userGroup.get(User.parameter, "messages", handler: getUsersMessages)
       // userGroup.get(User.parameter, handler: getUser)        
    }
    
    func createUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try User()
        try user.save()
        
        let tok = try Token(user: user)
        try tok.save()
        
        return tok
    }
    /*
    func allUsers(_ req: Request) throws -> ResponseRepresentable {
        let users = try User.all()
        return try users.makeJSON()
    }
    
    func getUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.parameters.next(User.self)
        return user
    }
    */
    
    func deleteUser(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        //let user = try req.parameters.next(User.self)
        try user.delete()
        return user
    }
    
    func getUsersMessages(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        //let user = try req.parameters.next(User.self)
        return try user.messages.all().makeJSON()
    }
    
    func deleteUsersMessages(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        //let user = try req.parameters.next(User.self)
        let messages = try Message.makeQuery().filter("user__id" == user.id).all()
        
        for msg in messages {
            try msg.delete()
        }
        
        return "Successfully deleted messages"
    }
    
}
