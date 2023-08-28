//
//  UIColor + extentions.swift
//  Tracker
//

import UIKit

extension UIColor {
    static var BackgroundDay: UIColor { UIColor(named: "Background(day)") ?? UIColor.gray }
    
    static var BackgroundNight: UIColor { UIColor(named: "Background(night)") ?? UIColor.darkGray }
    
    static var BlackDay: UIColor { UIColor(named: "Black(day)") ?? UIColor.black }
    
    static var Blue: UIColor { UIColor(named: "Blue") ?? UIColor.blue }
    
    static var Gray: UIColor { UIColor(named: "Gray") ?? UIColor.gray }
    
    static var LightGray: UIColor { UIColor(named: "Light Gray") ?? UIColor.lightGray }
    
    static var Red: UIColor { UIColor(named: "Red") ?? UIColor.red }
    
    static var defaultColor: UIColor { UIColor(named: "defaultColor") ?? UIColor.white}
    
    static var borderColor: UIColor { UIColor(named: "borderColor") ?? UIColor.green}
    
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
}
