import UIKit

extension UIColor {
    convenience init?(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        // Skip the # if present
        if hexString.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(after: scanner.string.startIndex)
        }
        
        var color: UInt64 = 0
        
        // Scan the hex value
        guard scanner.scanHexInt64(&color) else {
            return nil
        }
        
        let length = hexString.count - (hexString.hasPrefix("#") ? 1 : 0)
        
        switch length {
        case 3: // RGB (12-bit)
            let r = CGFloat((color & 0xF00) >> 8) / 15.0
            let g = CGFloat((color & 0x0F0) >> 4) / 15.0
            let b = CGFloat(color & 0x00F) / 15.0
            self.init(red: r, green: g, blue: b, alpha: 1.0)
            
        case 6: // RRGGBB (24-bit)
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: 1.0)
            
        case 8: // RRGGBBAA (32-bit)
            let r = CGFloat((color & 0xFF000000) >> 24) / 255.0
            let g = CGFloat((color & 0x00FF0000) >> 16) / 255.0
            let b = CGFloat((color & 0x0000FF00) >> 8) / 255.0
            let a = CGFloat(color & 0x000000FF) / 255.0
            self.init(red: r, green: g, blue: b, alpha: a)
            
        default:
            return nil
        }
    }
    
    // Computed property to get hex string from UIColor
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
}
