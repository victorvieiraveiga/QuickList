//
//  Item.swift
//  TodoList
//
//  Created by Victor Vieira Veiga on 29/10/20.
//  Copyright © 2020 Victor Vieira Veiga. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
   @objc dynamic var title: String = ""
   @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items" )

}
