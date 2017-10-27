//
//  PlistStorage.swift
//  minube
//
//  Created by Carlos Roig Salvador on 13/10/16.
//  Copyright © 2016 minube.com. All rights reserved.
//

import Foundation

class PlistStorageCoordinator : NSObject, StorageCoordinator {
    
    private let fileName : String
    var concurrentQueue: DispatchQueue {
        return DispatchQueue(label: "com.userDefaultsStorage", attributes: .concurrent)
    }
    
    var mainQueue: DispatchQueue {
        return DispatchQueue.main
    }
    private let serializer : Serializer
    
    init(_ fileName : String,_ serializer : Serializer) {
        self.fileName = fileName
        self.serializer = serializer
    }
    
    func getItems<T : Serializable>(completion: @escaping ([T]?) -> Void) {
        
        concurrentQueue.async {
            guard let data = try? Data(contentsOf: self.fileURL()),
                let serializedItems = self.serializer.serializedItems(from:data),
                serializedItems.count > 0
                else {
                    self.mainQueue.async {
                        completion(nil)
                    }
                    return
            }
            self.mainQueue.async {
                completion(self.serializer.deserialize(serializedItems))
            }
        }
    }
    
    func save<T : Serializable>(_ items: [T], completion: @escaping (Bool) -> Void) {
        
        let path = self.fileURL().path
        self.concurrentQueue.async {
            guard let data = self.serializer.data(from:items) else {
                completion(false)
                return
            }
            
            if !FileManager.default.fileExists(atPath: path) {
                FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
            }
            
            guard let _ = try? data.write(to: self.fileURL(), options: .atomic) else {
                self.mainQueue.async {
                    completion(false)
                }
                return;
            }
            self.mainQueue.async {
                completion(true)
            }
        }
    }
    
    private func fileURL() -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(fileURLWithPath:documentsPath)
        let locale =  Locale.preferredLanguages[0] as String
        return documentsURL.appendingPathComponent("\(self.fileName)-\(locale).plist")
    }
    
}
