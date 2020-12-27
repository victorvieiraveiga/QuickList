//
//  Category.swift
//  TodoList
//
//  Created by Victor Vieira Veiga on 29/10/20.
//  Copyright © 2020 Victor Vieira Veiga. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
   @objc dynamic var name : String = ""
    @objc dynamic var color : String = ""
    let items = List<Item>()
}
