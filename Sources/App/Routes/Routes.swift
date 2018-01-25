import AuthProvider
import VaporAPNS

extension Droplet {
    func setupRoutes(apns: VaporAPNS) throws {
        let tokenMiddleware = TokenAuthenticationMiddleware(User.self)
        let authed = grouped(tokenMiddleware)
        
        let messageController = MessageController(apns: apns)
        messageController.addRoutes(to: authed)
        
        let userController = UserController()
        userController.addRoutes(to: authed, drop: self)
    }
}
