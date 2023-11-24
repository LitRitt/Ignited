//
//  PopoverMenuViewController.swift
//  Ignited
//
//  Created by Riley Testut on 9/2/17.
//  Copyright © 2017 Riley Testut. All rights reserved.
//

import UIKit

import Roxas

class ListMenuViewController: UITableViewController
{
    var items: [MenuItem] {
        get { return self.dataSource.items }
        set { self.dataSource.items = newValue }
    }
    
    private let dataSource = RSTArrayTableViewDataSource<MenuItem>(items: [])
    
    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: 300, height: self.tableView.rowHeight * CGFloat(self.items.count))
        }
        set {}
    }
    
    init()
    {
        super.init(style: .plain)
        
        self.dataSource.cellConfigurationHandler = { (cell, item, indexPath) in
            cell.textLabel?.text = item.text
            cell.accessoryType = item.isSelected ? .checkmark : .none
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.tableView.dataSource = self.dataSource
        self.tableView.rowHeight = 44
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: RSTCellContentGenericCellIdentifier)
        
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemUltraThinMaterial)))
        self.tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemUltraThinMaterial))
        
        self.tableView.tableHeaderView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemUltraThinMaterial)))
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
}

extension ListMenuViewController
{
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {        
        let item = self.dataSource.item(at: indexPath)
        item.isSelected = !item.isSelected
        item.action(item)
        
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.backgroundColor = .clear
        cell.backgroundView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .systemUltraThinMaterial)))
    }
}
