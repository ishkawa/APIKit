import Foundation
import Himotoki

struct Repository: Decodable {
    let id: Int
    let name: String
    let owner: User

    static func decode(e: Extractor) -> Repository? {
        let create = { Repository($0) }
        return build(
            e <| "id",
            e <| "name",
            e <| "owner"
        ).map(create)
    }
}

struct User: Decodable {
    let id: Int
    let login: String
    let avatarURL: NSURL

    static func decode(e: Extractor) -> User? {
        let create = { User($0) }
        return build(
            e <| "id",
            e <| "login",
            (e <| "avatar_url").flatMap { NSURL(string: $0) }
        ).map(create)
    }
}
