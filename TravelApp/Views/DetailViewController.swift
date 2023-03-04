//
//  DetailViewController.swift
//  TravelApp
//
//  Created by Şükrü Özkoca on 4.03.2023.
//

import UIKit

class DetailViewController: DetailDesignViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
        tableView.rowHeight = 44
        tableView.sectionHeaderHeight = 1
        tableView.sectionFooterHeight = 1
        tableView.insetsContentViewsToSafeArea = true
        tableView.registerNib(GridViewCell.self)
    }
    
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(GridViewCell.self)
        return cell
    }

    override func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        let appearance = ElongationConfig.shared
        let headerHeight = appearance.topViewHeight + appearance.bottomViewHeight
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight - headerHeight
    }
}
