//
//  GridViewCell.swift
//  TravelApp
//
//  Created by Şükrü Özkoca on 4.03.2023.
//

import UIKit

class GridViewCell: UITableViewCell {

    @IBOutlet var stackView: UIStackView!

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        iterateSubviews(of: stackView)
        for case let stack as UIStackView in stackView.arrangedSubviews {
            iterateSubviews(of: stack)
        }
    }

    private func iterateSubviews(of view: UIStackView) {
        for case let imageView as UIImageView in view.arrangedSubviews {
            let imageName = String(arc4random_uniform(8) + 1)
            imageView.image = UIImage(named: imageName)
        }
    }
    
}
