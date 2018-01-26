//
//  PostsController.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 30.11.17.
//

import FluentProvider
import VaporAPNS

final class MessageController {
    
    let apns: VaporAPNS
    
    init(apns: VaporAPNS) {
        self.apns = apns
    }
    
    func addRoutes(to auth: RouteBuilder) {
        let messageGroup = auth.grouped("api", "message")
        messageGroup.post(handler: createMessage)
        messageGroup.get(Message.parameter, handler: getMessage)
        messageGroup.delete(Message.parameter, handler: deleteMessage)
    }
    
    func createMessage(_ req: Request) throws -> ResponseRepresentable {
        let userCredentials = try req.auth.assertAuthenticated(User.self)
        
        guard let content = req.data["content"]?.string else {
            throw Abort.badRequest
        }
        guard let signature = req.data["signature"]?.string else {
            throw Abort.badRequest
        }
        guard let sender_id = req.data["sender_id"]?.string else {
            throw Abort.badRequest
        }
        guard let receiver_id = req.data["receiver_id"]?.string else {
            throw Abort.badRequest
        }
      
        guard let user = try User.find(receiver_id) else {
            throw Abort.notFound
        }
        
        let message = try Message(content: content, signature: signature, user: user, sender_id: sender_id)
        try message.save()
        
        sendPushNotification(user: user, message: message)
        
        return message
    }
    
    func getMessage(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        let message = try req.parameters.next(Message.self)
        return message
    }
    
    func sendPushNotification(user: User, message: Message) {
        let payload = Payload(title: message.sender_id, body: message.content)
        let pushMessage = ApplePushMessage(priority: .immediately, payload: payload)
        let result = apns.send(pushMessage, to: user.push_token)
        
        switch result {
        case .success(let messageID, _, _):
            response["feedback"] = "Successfully sent a push notification"
            break
        case .error(_, _, let error):
            log.error("Could not send push notification (\(error))")
            throw Abort.notFound
        case .networkError(let error):
            log.error("Could not send push notification (\(error))")
            throw Abort.notFound
        }
    }

    func deleteMessage(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        let message = try req.parameters.next(Message.self)
        try message.delete()
        return message
    }
    
}
