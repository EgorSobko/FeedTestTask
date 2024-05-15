import Foundation

struct FeedItem: Codable {
    // I get used to make all properties optional in the DTO structures, because this way we do not depend on the backend
    // and if some field is changed there, at least we won't have a crash
    let name: String?
    let userId: Int?
    let age: Int?
    let loc: String?
    let aboutMe: String?
    let profilePicUrlString: String?
    var profilePicUrl: URL? {
        // I explicitly used such approach because for some reason if there's a non valid String in the response for URL, then
        // the decoding crashes, Apple decided to throw an error instead of just returning nil for URL? type
        return profilePicUrlString.flatMap(URL.init(string:))
    }
    
    // we could have used `snake case` in the Decoder, but since I have renamed profile picture key anyway, I thought
    // coding keys would be better
    enum CodingKeys: String, CodingKey {
        case name
        case userId = "user_id"
        case age
        case loc
        case aboutMe = "about_me"
        case profilePicUrlString = "profile_pic_url"
    }
}
