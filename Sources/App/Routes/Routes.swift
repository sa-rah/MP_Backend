import Vapor
import AuthProvider

extension Droplet {
    func setupRoutes() throws {
        let tokenMiddleware = TokenAuthenticationMiddleware(User.self)
        let authed = grouped(tokenMiddleware)
        
        let messageController = MessageController()
        messageController.addRoutes(to: authed)
        
        let userController = UserController()
        userController.addRoutes(to: authed, drop: self)
    }
}
