import Foundation


struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let baseApiUrlString: String
    let baseURLString: String
    let authURLString: String

    static let standard = AuthConfiguration(
        accessKey: "eQAonmsvWJxUHtGJv22w3xpomfXherp6Q-WzijhP8V0",
        secretKey: "0aLlKTCzGSjU30o7sSCSvzojQeuR-eb0Bgo7a0mPPGk",
        redirectURI: "urn:ietf:wg:oauth:2.0:oob",
        accessScope: "public+read_user+write_likes",
        baseApiUrlString: "https://api.unsplash.com",
        baseURLString: "https://unsplash.com",
        authURLString: "https://unsplash.com/oauth/authorize"
    )
    
    static let test = AuthConfiguration(
        accessKey: "test_key",
        secretKey: "test_secret",
        redirectURI: "test_uri",
        accessScope: "public+read_user",
        baseApiUrlString: "https://api.unsplash.com",
        baseURLString: "https://unsplash.com",
        authURLString: "https://unsplash.com/oauth/authorize"
    )
}
