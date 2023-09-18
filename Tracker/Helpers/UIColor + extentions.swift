//
//  UIColor + extentions.swift
//  Tracker
//

import UIKit

extension UIColor {
    static var BackgroundDay: UIColor { UIColor(named: "Background(day)") ?? UIColor.white }
    
    static var BlackDay: UIColor { UIColor(named: "Black(day)") ?? UIColor.black }
    
    static var Blue: UIColor { UIColor(named: "Blue") ?? UIColor.blue }
    
    static var Gray: UIColor { UIColor(named: "Gray") ?? UIColor.gray }
    
    static var LightGray: UIColor { UIColor(named: "Light Gray") ?? UIColor.lightGray }
    
    static var Red: UIColor { UIColor(named: "Red") ?? UIColor.red }
    
    static var defaultColor: UIColor { UIColor(named: "defaultColor") ?? UIColor.white}
    
    static var gradientRed: UIColor { UIColor(named: "gradientRed") ?? UIColor.red}
    static var gradientGreen: UIColor { UIColor(named: "gradientGreen") ?? UIColor.green}
    static var gradientBlue: UIColor { UIColor(named: "gradientBlue") ?? UIColor.blue}
    
    static let colorSelection: [UIColor] = [
        UIColor(named: "Color selection 1") ?? .red,
        UIColor(named: "Color selection 2") ?? .orange,
        UIColor(named: "Color selection 3") ?? .blue,
        UIColor(named: "Color selection 4") ?? .purple,
        UIColor(named: "Color selection 5") ?? .green,
        UIColor(named: "Color selection 6") ?? .systemPink,
        UIColor(named: "Color selection 7") ?? .systemPink,
        UIColor(named: "Color selection 8") ?? .blue,
        UIColor(named: "Color selection 9") ?? .green,
        UIColor(named: "Color selection 10") ?? .purple,
        UIColor(named: "Color selection 11") ?? .red,
        UIColor(named: "Color selection 12") ?? .systemPink,
        UIColor(named: "Color selection 13") ?? .orange,
        UIColor(named: "Color selection 14") ?? .blue,
        UIColor(named: "Color selection 15") ?? .purple,
        UIColor(named: "Color selection 16") ?? .systemPurple,
        UIColor(named: "Color selection 17") ?? .systemPurple,
        UIColor(named: "Color selection 18") ?? .green
    ]
    
    static func areAlmostEqual(color1: UIColor, color2: UIColor, tolerance: CGFloat = 0.01) -> Bool {
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        
        color1.getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        color2.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        
        return abs(red1 - red2) <= tolerance &&
               abs(green1 - green2) <= tolerance &&
               abs(blue1 - blue2) <= tolerance &&
               abs(alpha1 - alpha2) <= tolerance
    }
}
