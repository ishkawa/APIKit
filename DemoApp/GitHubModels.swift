import Foundation

class Repository {
    let id: Int!
    let name: String!
    let owner: User!
    
    init?(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int
        name = dictionary["name"] as? String
        
        if let userDictionary = dictionary["owner"] as? NSDictionary {
            owner = User(dictionary: userDictionary)
        }
        
        if id == nil || name == nil || owner == nil {
            return nil
        }
    }
}

class User {
    let id: Int!
    let login: String!
    let avatarURL: NSURL!
    
    init?(dictionary: NSDictionary) {
        id = dictionary["id"] as? Int
        login = dictionary["login"] as? String
        
        if let string = dictionary["avatar_url"] as? String {
            avatarURL = NSURL(string: string)
        }
        
        if id == nil || login == nil || avatarURL == nil {
            return nil
        }
    }
}
