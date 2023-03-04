//
//  DesignViewController.swift
//  TravelApp
//
//  Created by Şükrü Özkoca on 4.03.2023.
//

import UIKit

@available(iOS 10, *)
fileprivate var interaction: UIPreviewInteraction!


open class DesignViewController: SwipableTableViewController {

    // MARK: Public properties

    public var expandedIndexPath: IndexPath?

    public var shouldExpand = true

    public enum State {
        case normal
        case expanded
    }
    
    public var state: State = .normal {
        didSet {
            let expanded = state == .expanded
            tapGesture.isEnabled = expanded
            tableView.allowsSelection = !expanded
            tableView.panGestureRecognizer.isEnabled = !expanded
        }
    }

    // MARK: Private properties

    fileprivate var cellStatesDictionary: [IndexPath: Bool] = [:]
    fileprivate var tapGesture: UITapGestureRecognizer!
    fileprivate var longPressGesture: UILongPressGestureRecognizer!
    fileprivate var config: ElongationConfig {
        return ElongationConfig.shared
    }

    fileprivate var parallaxConfigured = false
    fileprivate var shouldCommitPreviewAction = false

    // MARK: Lifecycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard config.isParallaxEnabled, !parallaxConfigured else { return }
        parallaxConfigured = true
        scrollViewDidScroll(tableView)
    }

    // MARK: - Actions
    
    public func collapseCells(animated: Bool = true) {
        for (path, state) in cellStatesDictionary where state {
            moveCells(from: path, force: false, animated: animated)
        }
    }

    public func expandCell(at indexPath: IndexPath) {
        guard state == .normal else {
            print("The view is in `expanded` state already. You must collapse the cells before calling this method.")
            return
        }
        moveCells(from: indexPath, force: true)
    }

    open func openDetailView(for _: IndexPath) {
        let viewController = DetailDesignViewController()
        expand(viewController: viewController)
    }

    public func expand(viewController: DetailDesignViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        present(viewController, animated: animated, completion: completion)
    }

    // MARK: Private

    @objc fileprivate func tableViewTapped(_ gesture: UITapGestureRecognizer) {
        guard let path = expandedIndexPath else { return }

        let location = gesture.location(in: tableView)
        let realPoint = tableView.convert(location, to: UIScreen.main.coordinateSpace)

        let cellFrame = tableView.rectForRow(at: path).offsetBy(dx: -tableView.contentOffset.x, dy: -tableView.contentOffset.y)

        if realPoint.y < cellFrame.minY || realPoint.y > cellFrame.maxY {
            collapseCells()
            return
        }

        guard let indexPath = tableView.indexPathForRow(at: location), let cell = tableView.cellForRow(at: indexPath) as? ElongationCell else { return }
        let point = cell.convert(location, from: tableView)

        let elongationCellTouchAction = config.cellTouchAction

        guard let touchedView = cell.hitTest(point, with: nil) else {
            collapseCells()
            return
        }

        if touchedView === cell.bottomView || touchedView.superview === cell.bottomView {
            switch elongationCellTouchAction {
            case .expandOnBoth, .expandOnBottom, .collapseOnTopExpandOnBottom:
                openDetailView(for: path)
            case .collapseOnBoth, .collapseOnBottomExpandOnTop: collapseCells()
            default: break
            }
        } else if touchedView === cell.scalableView || touchedView.superview === cell.scalableView || touchedView.superview === cell.topView || touchedView === cell.topView {
            switch elongationCellTouchAction {
            case .collapseOnBoth, .collapseOnTopExpandOnBottom: collapseCells()
            case .collapseOnBottomExpandOnTop, .expandOnBoth, .expandOnTop: openDetailView(for: path)
            default: break
            }
        } else {
            switch elongationCellTouchAction {
            case .expandOnBoth: openDetailView(for: path)
            case .collapseOnBoth: collapseCells()
            default: break
            }
        }
    }

    fileprivate func moveCells(from indexPath: IndexPath, force: Bool? = nil, animated: Bool = true) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ElongationCell else { return }
        let shouldExpand = force ?? !(cellStatesDictionary[indexPath] ?? false)
        shouldCommitPreviewAction = false
        cell.expand(shouldExpand, animated: animated) { _ in
            self.shouldCommitPreviewAction = true
        }
        cellStatesDictionary[indexPath] = shouldExpand

        // Change `self` properties
        state = shouldExpand ? .expanded : .normal
        expandedIndexPath = shouldExpand ? indexPath : nil

        for case let elongationCell as ElongationCell in tableView.visibleCells where elongationCell != cell {
            elongationCell.dim(shouldExpand)
            elongationCell.hideSeparator(shouldExpand, animated: animated)
        }

        if !animated {
            UIView.setAnimationsEnabled(false)
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        if !animated {
            UIView.setAnimationsEnabled(true)
        }

        if force == nil {
            let cellFrame = cell.frame
            let scrollToFrame = cellFrame
            if scrollToFrame.maxY > tableView.contentSize.height {
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            } else {
                tableView.scrollRectToVisible(scrollToFrame, animated: animated)
            }
        }

        guard !shouldExpand else { return }
        for case let elongationCell as ElongationCell in tableView.visibleCells where elongationCell != cell {
            elongationCell.parallaxOffset(offsetY: tableView.contentOffset.y, height: tableView.bounds.height)
        }
    }

    override func gestureRecognizerSwiped(_ gesture: UIPanGestureRecognizer) {
        guard config.isSwipeGesturesEnabled else { return }
        let point = gesture.location(in: tableView)
        guard let path = tableView.indexPathForRow(at: point), path == expandedIndexPath, let cell = tableView.cellForRow(at: path) as? ElongationCell else {
            swipedView = nil
            return
        }
        let convertedPoint = cell.convert(point, from: tableView)
        if gesture.state == .began {
            if cell.scalableView.frame.contains(convertedPoint) {
                swipedView = cell.scalableView
            } else if cell.bottomView.frame.contains(convertedPoint) {
                swipedView = cell.bottomView
            } else {
                swipedView = nil
                return
            }
            startY = convertedPoint.y
        }
        guard let swipedView = swipedView else { return }

        let newY = convertedPoint.y
        let goingToBottom = startY < newY

        let rangeReached = abs(startY - newY) > 50
        if swipedView == cell.scalableView && rangeReached {
            if goingToBottom {
                collapseCells(animated: true)
            } else {
                openDetailView(for: path)
            }
            startY = newY
        } else if swipedView == cell.bottomView && rangeReached {
            if goingToBottom {
                openDetailView(for: path)
            } else {
                collapseCells(animated: true)
            }
            startY = newY
        }
    }

    @objc fileprivate func longPressGestureAction(_ sender: UILongPressGestureRecognizer) {
        let location = sender.location(in: tableView)
        guard sender.state == .began, let path = tableView.indexPathForRow(at: location) else { return }
        expandedIndexPath = path
        moveCells(from: path)
    }
}

// MARK: - Setup

private extension DesignViewController {

    // MARK: - Setup

    func setup() {
        setupTableView()
        setupTapGesture()

        if #available(iOS 10, *), traitCollection.forceTouchCapability == .available, config.forceTouchPreviewInteractionEnabled {
            interaction = UIPreviewInteraction(view: view)
            interaction.delegate = self
        } else if config.forceTouchPreviewInteractionEnabled {
            setupLongPressGesture()
        }
    }

    private func setupTableView() {
        tableView.separatorStyle = .none
    }

    private func setupTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(_:)))
        tapGesture.isEnabled = false
        tableView.addGestureRecognizer(tapGesture)
    }

    private func setupLongPressGesture() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureAction(_:)))
        tableView.addGestureRecognizer(longPressGesture)
    }
}

// MARK: - TableView

extension DesignViewController {

    /// Must call `super` if you override this method in subclass.
    open override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ElongationCell else { return }
        let expanded = state == .expanded
        cell.dim(expanded, animated: true)

        // Remove separators from top and bottom cells.
        guard config.customSeparatorEnabled else { return }
        cell.hideSeparator(expanded, animated: expanded)
        let numberOfRowsInSection = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row == 0 || indexPath.row == numberOfRowsInSection - 1 {
            let separator = indexPath.row == 0 ? cell.topSeparatorLine : cell.bottomSeparatorLine
            separator?.backgroundColor = UIColor.black
        } else {
            cell.topSeparatorLine?.backgroundColor = config.separatorColor
            cell.bottomSeparatorLine?.backgroundColor = config.separatorColor
        }
    }

    open override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard shouldExpand else { return }
        DispatchQueue.main.async {
            self.expandedIndexPath = indexPath
            self.openDetailView(for: indexPath)
        }
    }

    open override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let isExpanded = cellStatesDictionary[indexPath] ?? false
        let frontViewHeight = config.topViewHeight
        let expandedCellHeight = config.bottomViewHeight + frontViewHeight - config.bottomViewOffset
        return isExpanded ? expandedCellHeight : frontViewHeight
    }

    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === tableView, config.isParallaxEnabled else { return }
        for case let cell as ElongationCell in tableView.visibleCells {
            cell.parallaxOffset(offsetY: tableView.contentOffset.y, height: tableView.bounds.height)
        }
    }
}

// MARK: - 3D Touch Preview Interaction

@available(iOS 10.0, *)
extension DesignViewController: UIPreviewInteractionDelegate {

    public func previewInteractionDidCancel(_: UIPreviewInteraction) {
        collapseCells()

        panGestureRecognizer.isEnabled = true

        tableView.allowsSelection = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.tableView.allowsSelection = true
        }
    }

    public func previewInteraction(_ previewInteraction: UIPreviewInteraction, didUpdatePreviewTransition _: CGFloat, ended: Bool) {
        guard ended else { return }
        panGestureRecognizer.isEnabled = false
        let location = previewInteraction.location(in: tableView)
        guard let path = tableView.indexPathForRow(at: location) else { return }
        if path == expandedIndexPath {
            openDetailView(for: path)
            previewInteraction.cancel()
        } else {
            moveCells(from: path)
        }
    }

    public func previewInteraction(_: UIPreviewInteraction, didUpdateCommitTransition _: CGFloat, ended: Bool) {
        guard ended else { return }
        guard let path = expandedIndexPath else { return }
        panGestureRecognizer.isEnabled = false
        if shouldCommitPreviewAction {
            openDetailView(for: path)
        } else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                self.openDetailView(for: path)
            }
        }
    }
}

// MARK: - Transition

extension DesignViewController: UIViewControllerTransitioningDelegate {

    public func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ElongationTransition(presenting: false)
    }

    public func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ElongationTransition(presenting: true)
    }
}

