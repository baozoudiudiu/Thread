//
//  SGCDViewController.swift
//  Thread
//
//  Created by chenwang on 2018/1/19.
//  Copyright © 2018年 chenwang. All rights reserved.
//

import UIKit

let cellId = "cellId"

class SGCDViewController : UIViewController, UITableViewDelegate, UITableViewDataSource{
    //MARK: Property
    lazy var tableView:UITableView = {
        let tb:UITableView = UITableView(frame: self.view.frame, style: .plain)
        tb.tableFooterView = UIView()
        tb.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellId)
        tb.delegate = self
        tb.dataSource = self
        return tb
    }()
    
    lazy var dataSource:[String] = {
        return ["test"]
    }()
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    //MARK: Configure UI
    private func configureUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = "GCD"
        self.view.addSubview(self.tableView)
    }
    
    //MARK: UITableViewDelegate, UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if(cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        }
        cell?.textLabel?.text = self.dataSource[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: 内存警告
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
