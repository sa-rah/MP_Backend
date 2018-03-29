@_exported import Vapor

import HTTP
import AuthProvider
import VaporAPNS

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
    }
}
