import UIKit

// MARK: - Colors
enum AppColors {
    static let background = UIColor(hex: "#1A1B22")
    static let buttonBackground = UIColor.white
    static let textPrimary = UIColor.systemGray
    static let textSecondary = UIColor.white
    static let accent = UIColor.systemBlue
    static let tabBarUnselected = UIColor.systemGray
}

// MARK: - Fonts
enum AppFonts {
    static let title = UIFont.systemFont(ofSize: 23, weight: .bold)
    static let body = UIFont.systemFont(ofSize: 13, weight: .regular)
    static let caption = UIFont.systemFont(ofSize: 14, weight: .medium)
}

// MARK: - Layout
enum AppLayout {
    static let spacingHorizontal: CGFloat = 16
    static let spacingVertical: CGFloat = 8
    static let spacingBetweenLines: CGFloat = 8
    static let cornerRadius: CGFloat = 15
    static let logoutImageSize: CGFloat = 24
    static let likeImageSize: CGFloat = 44
    static let avatarSize: CGFloat = 70
    static let profileTopSpacing: CGFloat = 32
}

enum UnsplashConst {
    static let accessKey = "eQAonmsvWJxUHtGJv22w3xpomfXherp6Q-WzijhP8V0"
    static let secretKey = "0aLlKTCzGSjU30o7sSCSvzojQeuR-eb0Bgo7a0mPPGk"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"

}
