//
//  SwipableTableViewController.swift
//  TravelApp
//
//  Created by Şükrü Özkoca on 4.03.2023.
//

import UIKit

import UIKit

/**

 UITableViewController subclass.

 Base class for `ElongationViewController` & `ElongationDetailViewController`.

 */
open class SwipableTableViewController: UITableViewController, UIGestureRecognizerDelegate {

    var panGestureRecognizer: UIPanGestureRecognizer!
    var startY: CGFloat = 0
    var swipedView: UIView?

    /// :nodoc:
    open override func viewDidLoad() {
        super.viewDidLoad()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizerSwiped(_:)))
        panGestureRecognizer.delegate = self
        tableView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func gestureRecognizerSwiped(_: UIPanGestureRecognizer) {}

    /// :nodoc:
    public func gestureRecognizer(_: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer) -> Bool {
        return true
    }
}
