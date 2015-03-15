import Foundation

struct Repository {
    let id: Int
    let name: String
    let owner: User
    
    init?(dictionary: NSDictionary) {
        if 
        let id = dictionary["id"] as? Int,
        let userDictionary = dictionary["owner"] as? NSDictionary,
        let name = dictionary["name"] as? String,
        let user = User(dictionary: userDictionary) {
            self.id = id
            self.name = name
            self.owner = user
        } else {
            return nil
        }
    }
}

struct User {
    let id: Int
    let login: String
    let avatarURL: NSURL
    
    init?(dictionary: NSDictionary) {
        if
        let id = dictionary["id"] as? Int,
        let login = dictionary["login"] as? String,
        let string = dictionary["avatar_url"] as? String,
        let avatarURL = NSURL(string: string) {
            self.id = id
            self.login = login
            self.avatarURL = avatarURL
        } else {
            return nil
        }
    }
}
