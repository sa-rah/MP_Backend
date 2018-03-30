//
//  MessageController.swift
//  BackendPackageDescription
//
//  Created by Sarah Sauseng on 30.11.17.
//

import Foundation
import FluentProvider
import VaporAPNS
import MongoKitten
import HTTP

final class MessageController {
    
    let apns: VaporAPNS
    let drop: Droplet
    
    init(apns: VaporAPNS, drop: Droplet) {
        self.apns = apns
        self.drop = drop
    }
    
    func addRoutes(to auth: RouteBuilder) {
        let messageGroup = auth.grouped("api", "message")
        messageGroup.post(handler: createMessage)
        messageGroup.get(Message.parameter, handler: getMessageAttachment)
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
        
        // ---- attach file
        
        var name = ""
        
        let fileData = req.formData?["attachment"]?.part.body
        
        if let fileData = fileData {
            let workPath = drop.config.workDir
            let fileEnd = (req.formData?["attachment"]?.part.headers[HeaderKey("Content-Disposition")])!.components(separatedBy: ".")[1]
            name = UUID().uuidString + "." + fileEnd.substring(to: fileEnd.index(before: fileEnd.endIndex))
            let fileFolder = "Public/files"
            let saveURL = URL(fileURLWithPath: workPath).appendingPathComponent(fileFolder, isDirectory: true).appendingPathComponent(name, isDirectory: false)
            
            do {
                let data = Data(bytes: fileData)
                try data.write(to: saveURL)
            } catch {
                throw Abort.badRequest
            }
        }
        
        let message = try Message(content: content, attachment: name, signature: signature, user: user, sender_id: sender_id)
        try message.save()
        
        try sendPushNotification(user: user, message: message)
        
        var json = JSON()
        try json.set("success", true)
        
        return json
    }
    
    func getMessageAttachment(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        let message = try req.parameters.next(Message.self)
        
        /*let file: GridFS.File? = try fs.findOne(byID: message.attachment!)
        
        var attachment = Array<Bytes>()
        
        for chunk in file! {
            attachment.append(chunk.data)
        }*/
    
        let headerKey = HeaderKey("Content-Type")
        return  Response(status: .ok, headers: [headerKey: "image/png"], body: message.attachment)
    }
    
    func deleteMessage(_ req: Request) throws -> ResponseRepresentable {
        let user = try req.auth.assertAuthenticated(User.self)
        let message = try req.parameters.next(Message.self)
        try message.delete()
        return message
    }
    
    // additional methods
    
    func uploadFile() {
        
    }
    
    func sendPushNotification(user: User, message: Message) {
        print("sending notification")
        let payload = Payload(title: "New message", body: "You've received a new message!")
        let pushMessage = ApplePushMessage(priority: .immediately, payload: payload)
        let result = apns.send(pushMessage, to: user.push_token)
        
        switch result {
            case .success(let messageID, _, _):
                print("Successfully sent a push notification")
                break
            case .error(_, _, let error):
                print("Could not send push notification (\(error))")
                break
            case .networkError(let error):
                print("Could not send push notification (\(error))")
                break
        }
    }
    
}
