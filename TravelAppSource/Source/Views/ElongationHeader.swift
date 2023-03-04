//
//  ElongationHeader.swift
//  TravelApp
//
//  Created by Şükrü Özkoca on 4.03.2023.
//

import Foundation
import UIKit

/// Expanded copy of `ElongationCell`.
open class ElongationHeader: UIView, Expandable {

    /// Container of all the subviews.
    public var contentView: UIView = UIView()

    /// View on top half of `contentView`.
    /// Add here all the views which wont be scaled and must stay on their position.
    public var topView: UIView!

    /// This is the front view which can be scaled if `scaleFactor` was configured in `ElongationConfig`.
    /// Also to this view can be applied 'parallax' effect.
    public var scalableView: UIView!

    /// The view which comes from behind the cell when you tap on the cell.
    public var bottomView: UIView!

    /// `top` constraint of `bottomView`.
    public var bottomViewTopConstraint: NSLayoutConstraint!

    fileprivate var appearance: ElongationConfig {
        return ElongationConfig.shared
    }

    open override var intrinsicContentSize: CGSize {
        let height = appearance.topViewHeight + appearance.bottomViewHeight
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
    }
}

// MARK: - ElongationCell -> ElongationHeader

extension ElongationCell {

    var elongationHeader: ElongationHeader {
        guard let copy = cellCopy else { return ElongationHeader() }
        let elongationHeader = ElongationHeader()
        elongationHeader.contentView = copy.contentView
        elongationHeader.topView = copy.topView
        elongationHeader.scalableView = copy.scalableView
        elongationHeader.bottomView = copy.bottomView
        elongationHeader.bottomViewTopConstraint = copy.bottomViewTopConstraint
        elongationHeader.addSubview(copy.contentView)
        return elongationHeader
    }
}
