//
//  Category.swift
//  ToDo-Realm
//
//  Created by kamilcal on 13.12.2022.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let items = List<Item>()
}
