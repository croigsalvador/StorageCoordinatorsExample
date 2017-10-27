//
//  ViewController.swift
//  StorageCoordinatorsExample
//
//  Created by Carlos Roig on 27/10/17.
//  Copyright © 2017 CRS. All rights reserved.
//

import UIKit

class ItemListViewController: UITableViewController {
    
    
    private let inMemoryItems = [Item(id: "1", name: "InMemory 1", description: "Description for InMemory 1"),
                                     Item(id: "2", name: "InMemory 2", description: "Description for InMemory 2"),
                                     Item(id: "3", name: "InMemory 3", description: "Description for InMemory 3")]
    private let userDefaultsItems = [Item(id: "11", name: "Defaults 1", description: "Description for Defaults 1"),
                                     Item(id: "22", name: "Defaults 2", description: "Description for Defaults 2"),
                                     Item(id: "33", name: "Defaults 3", description: "Description for Defaults 3")]
    private let plistItems = [Item(id: "111", name: "Plist 1", description: "Description for Plist 1"),
                                     Item(id: "222", name: "Plist 2", description: "Description for Plist 2"),
                                     Item(id: "333", name: "Plist 3", description: "Description for Plist 3")]
    
    var items: [Item] = [Item]()
    
    fileprivate let inMemoryStorage = InMemoryStorageCoordinator()
    fileprivate let userDefaultsStorage = UserDefaultsStorageCoordinator(UserDefaults.standard, "Items", ItemSerializer())
    fileprivate let pListStorage = PlistStorageCoordinator("Items", ItemSerializer())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInMemory()
        setupDefaults()
        setupPlist()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier:String(describing: UITableViewCell.self))
    }
    
    private func reload(_ items:[Item]?) {
        guard let items = items else {
            return
        }
        self.items.append(contentsOf:items)
        tableView.reloadData()
    }
    
    private func setupInMemory() {
        inMemoryStorage.save(inMemoryItems) { (success) in
            if success {
                self.inMemoryStorage.getItems(completion: { (items) in
                    self.reload(items)
                })
            }
            print("Error")
        }
    }
    
    private func setupDefaults() {
        userDefaultsStorage.save(userDefaultsItems) { (success) in
            if success {
                self.obtainDefaultItems({ (items) in
                    self.reload(items)
                })
            }
            print("Error")
        }
    }
    
    private func setupPlist() {
        pListStorage.save(plistItems) { (success) in
            if success {
                self.obtainPlistItems({ (items) in
                    self.reload(items)
                })
            }
            print("Error")
        }
    }
    
    private func obtainDefaultItems(_ completion: @escaping ([Item]?)->()){
        userDefaultsStorage.getItems(completion:completion)
    }
    
    private func obtainPlistItems(_ completion: @escaping ([Item]?)->()){
        pListStorage.getItems(completion:completion)
    }
}

extension ItemListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier:String(describing: UITableViewCell.self), for: indexPath)
        let item = items[indexPath.item]
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.description
        return cell
    }
}

