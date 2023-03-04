//
//  Expandable.swift
//  TravelApp
//
//  Created by Şükrü Özkoca on 4.03.2023.
//

import Foundation
import UIKit

protocol Expandable {
    var contentView: UIView { get }
    var topView: UIView! { get set }
    var scalableView: UIView! { get set }
    var bottomView: UIView! { get set }
    var bottomViewTopConstraint: NSLayoutConstraint! { get set }
}
