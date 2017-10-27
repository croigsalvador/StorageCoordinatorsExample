//
//  Serializator.swift
//  minube
//
//  Created by Carlos Roig Salvador on 30/11/16.
//  Copyright © 2016 minube.com. All rights reserved.
//

import Foundation

protocol Serializer {
    func data<T:Serializable>(from serializableItems : [T]) -> Data?
    func deserialize<T:Serializable>(_ serializedItems : [[String : Any]]) -> [T]
    func serializedItems(from data : Data) -> [[String : Any]]?
}

struct ItemSerializer : Serializer {
        
        func data<T:Serializable>(from serializableItems : [T]) -> Data? {
            
            var serializedItems = [[String : Any]]()
            
            for item in serializableItems {
                serializedItems.append(item.serialize())
            }
            
            guard let serializedData = try? PropertyListSerialization.data(fromPropertyList: serializedItems, format:.binary, options:0) else {
                return nil;
            }
            return serializedData
        }
        
        func serializedItems(from data : Data) -> [[String : Any]]? {
            guard let serilizedItems = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainers, format: nil) as? [[String : Any]] else {
                return nil
            }
            return serilizedItems
        }
        
        func deserialize<T:Serializable>(_ serializedItems : [[String : Any]]) -> [T] {
            var items = [T]()
            for serializedItem in serializedItems {
                if let item = T(byDeserializing:serializedItem){
                    items.append(item)
                }
            }
            return items
        }
        
    }
