//
//  View+Extension.swift
//  user-down
//
//  Created by AmineBj on 11/6/24.
//

import SwiftUI

extension View {
    
    //View Alignment
    @ViewBuilder
    func hSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
        
    }
    func vSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    //Disable with opacity
    @ViewBuilder
    func displayWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.5 : 1)
    }
}

//enum fonts
enum Astrofont: String {
    case regular = "PlayfulTime-BLBB8"
}
extension Font {
    
    static func customfont(_ font: Astrofont, fontSize: CGFloat) -> Font {
        custom(font.rawValue, size: fontSize)
    }
}
extension Notification.Name {
    static let userLoggedOut = Notification.Name("userLoggedOut")
}
// MARK: Safe Array Subscript Extension
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
