//
//  UserDefaultsStorageCoordinator.swift
//  minube
//
//  Created by Carlos Roig Salvador on 24/10/16.
//  Copyright © 2016 minube.com. All rights reserved.
//

import Foundation


class UserDefaultsStorageCoordinator : NSObject, StorageCoordinator {
    
    fileprivate let modelKey : String
    fileprivate let userDefaults : UserDefaults
    
    var concurrentQueue: DispatchQueue {
        return DispatchQueue(label: "com.userDefaultsStorage", attributes: .concurrent)
    }
    
    var mainQueue: DispatchQueue {
        return DispatchQueue.main
    }
    
    private let serializer : Serializer
    
    init(_ userDefaults : UserDefaults,_ modelKey : String,_ serializer : Serializer) {
        self.userDefaults = userDefaults
        self.modelKey = modelKey
        self.serializer = serializer
    }
    
    func getItems<T : Serializable>(completion: @escaping ([T]?) -> Void) {
        
        concurrentQueue.async {
            guard  let data = self.userDefaults.data(forKey: self.modelKey), let serializedItems = self.serializer.serializedItems(from: data), serializedItems.count > 0 else {
                self.mainQueue.async {
                    completion(nil)
                }
                return
            }
            self.mainQueue.async {
                completion(self.serializer.deserialize(serializedItems) as [T])
            }
        }
    }
    
    func save<T : Serializable>(_ items: [T], completion: @escaping (Bool) -> Void) {
        self.concurrentQueue.async {
            guard let data = self.serializer.data(from: items) else {
                self.mainQueue.async {
                    completion(false)
                }
                return
            }
            
            self.userDefaults.set(data, forKey: self.modelKey)
            self.mainQueue.async {
                completion(self.synchronizeUserDefaults())
            }
        }
    }
    
    func getItems<T:Serializable>()-> [T]? {
        guard  let data = self.userDefaults.data(forKey: self.modelKey), let serializedItems = self.serializer.serializedItems(from: data), serializedItems.count > 0 else {
            return nil
        }
        return self.serializer.deserialize(serializedItems) as [T]
    }
    
    func removeAll() {
        userDefaults.removeObject(forKey: modelKey)
        userDefaults.synchronize()
    }
    
    
    func synchronizeUserDefaults() -> Bool {
        let synchronize = self.userDefaults.synchronize()
        return synchronize
    }
    
}
