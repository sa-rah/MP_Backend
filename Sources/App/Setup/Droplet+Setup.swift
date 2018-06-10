@_exported import Vapor

import HTTP
import AuthProvider
import VaporAPNS
import Jobs
import Foundation

extension Droplet {
    
    public func setup() throws {
       guard
            let teamIdentifier = config["apns", "teamIdentifier"]?.string,
            let APNSAuthKeyID = config["apns", "APNSAuthKeyID"]?.string,
            let APNSAuthKeyPath = config["apns", "APNSAuthKeyPath"]?.string,
            let identifier = config["apns", "identifier"]?.string,
            let mongo = config["mongo", "url"]?.string
            else {
                throw Abort.serverError
        }
        
        let options = try Options(topic: identifier, teamId: teamIdentifier, keyId: APNSAuthKeyID, keyPath: APNSAuthKeyPath)
        let vaporAPNS = try VaporAPNS(options: options)
        
        try setupRoutes(apns: vaporAPNS)
        
        let minute: TimeInterval = 60.0
        let hour: TimeInterval = 60.0 * minute
        let days: TimeInterval = 24 * hour * 7
        
        Jobs.add(interval: .days(7)) {
            for message in try Message.all() {
                if message.date_sent >= days {
                   try message.delete()
                }
            }
        }
    }
}
