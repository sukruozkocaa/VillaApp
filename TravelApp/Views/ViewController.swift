//
//  ViewController.swift
//  TravelApp
//
//  Created by Şükrü Özkoca on 4.03.2023.
//

import UIKit

class ViewController: DesignViewController {
    
    var dataSource: [Villa] = Villa.testData
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 44
        tableView.sectionHeaderHeight = 28
        tableView.sectionFooterHeight = 28
        tableView.insetsContentViewsToSafeArea = true
        setup()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func openDetailView(for indexPath: IndexPath) {
        let id = String(describing: DetailViewController.self)
        let detailViewController = DetailViewController()
        let villa = dataSource[indexPath.row]
        detailViewController.title = villa.title
        expand(viewController: detailViewController)
    }
}

private extension ViewController {
    func setup() {
        tableView.backgroundColor = UIColor.black
        tableView.registerNib(DemoElongationCell.self)
    }
}

extension ViewController {
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt _: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(DemoElongationCell.self)
        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.tableView(tableView, willDisplay: cell, forRowAt: indexPath)
        guard let cell = cell as? DemoElongationCell else { return }

        let villa = dataSource[indexPath.row]

        let attributedLocality = NSMutableAttributedString(string: villa.locality.uppercased(), attributes: [
            NSAttributedString.Key.font: UIFont(name: "GillSans-Bold", size: 30),
            NSAttributedString.Key.kern: 8.2,
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ])

        cell.topImageView?.image = UIImage(named: villa.imageName)
        cell.localityLabel?.attributedText = attributedLocality
        cell.countryLabel?.text = villa.country
        cell.aboutTitleLabel?.text = villa.title
        cell.aboutDescriptionLabel?.text = villa.description
    }
}

