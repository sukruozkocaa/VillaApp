//
//  UIEdgeInsets.swift
//  TravelApp
//
//  Created by Şükrü Özkoca on 4.03.2023.
//

import Foundation
import UIKit

public extension UIEdgeInsets {
    
    init(_ padding: CGFloat) {
        self.init()
        top = CGFloat(padding)
        bottom = CGFloat(padding)
        left = CGFloat(padding)
        right = CGFloat(padding)
    }

    init(padding: CGFloat, sidePadding: CGFloat = 0) {
        self.init()
        top = padding; bottom = padding
        left = sidePadding; right = sidePadding
    }

    init(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil, otherSides: CGFloat? = nil) {
        self.init()
        self.top = top ?? otherSides ?? 0
        self.left = left ?? otherSides ?? 0
        self.bottom = bottom ?? otherSides ?? 0
        self.right = right ?? otherSides ?? 0
    }
}
