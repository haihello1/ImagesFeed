import UIKit

struct ProfileResult: Decodable {
    let username: String?
    let firstName: String?
    let lastName: String?
    let bio: String?
    
    enum CodingKeys: String, CodingKey {
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case bio
    }
    var fullName: String {
        return [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }
}

struct Profile {
    let username: String
    let name: String
    let loginName: String
    let bio: String
}

/// Profile avatar
struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String
}

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}
