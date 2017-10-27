//
//  Item.swift
//  StorageCoordinatorsExample
//
//  Created by Carlos Roig on 27/10/17.
//  Copyright © 2017 CRS. All rights reserved.
//

import Foundation

struct Item {
    let id: String
    let name: String
    let description: String
    
    init(id:String, name:String, description:String) {
        self.id = id
        self.name = name
        self.description = description
    }
}

extension Item : Serializable {
    static let kPropertyUserSessionId = "id"
    static let kPropertyUserSessionName = "name"
    static let kPropertyUserSessionDescription = "description"
    
    func serialize() -> [String : Any] {
        return [Item.kPropertyUserSessionId:self.id as Any,
                Item.kPropertyUserSessionName:self.name as Any,
                Item.kPropertyUserSessionDescription:self.description as Any
        ]
    }
    
    init?(byDeserializing dictionary: [String : Any]) {
        guard let id = dictionary[Item.kPropertyUserSessionId] as? String,
            let name = dictionary[Item.kPropertyUserSessionName] as? String,
            let description = dictionary[Item.kPropertyUserSessionDescription] as? String
            else {
                return nil
        }
        self.init(id:id, name:name, description: description)
    }
}
