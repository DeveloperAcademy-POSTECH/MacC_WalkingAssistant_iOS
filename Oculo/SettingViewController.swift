//
//  SettingViewController.swift
//  Oculo
//
//  Created by Dongjin Jeon on 2022/10/27.
//  Copyright © 2022 Intelligent ATLAS. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController {

    lazy var logoImageView = UIImageView(image: UIImage(named: "settingViewLogo"))
    lazy var tableView = UITableView(frame: .zero, style: .insetGrouped)
    lazy var lastLableView = UILabel()

    // TODO: localizing is needed
    let data = [["멤버십", "보행정보 제공 동의"],
                ["이용 약관", "개인정보 보호", "사용권 조항", "고객센터"]]
    let localizedData = [["Membership", "Agreement on sending walking data"],
                         ["Terms of agreement", "Privacy policy", "License", "Contact us"]]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        view.addSubview(logoImageView)
        view.addSubview(tableView)
        view.addSubview(lastLableView)

        tableView.dataSource = self
        lastLableView.text = """
        Copyright(c) 2022. IntelligentATLAS.
        All Rights Reserved.
        """
        lastLableView.lineBreakMode = .byWordWrapping
        lastLableView.numberOfLines = 0
        lastLableView.textAlignment = .center

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        lastLableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate(
        [
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tableView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            lastLableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lastLableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

}

extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        data.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: .none)
        cell.textLabel?.text = data[indexPath.section][indexPath.row]
        return cell
    }
}
