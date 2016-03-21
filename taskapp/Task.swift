//
//  Task.swift
//  taskapp
//
//  Created by swiftdev on 2016/03/19.
//  Copyright © 2016年 kiyoko.ohashi. All rights reserved.
//

import RealmSwift

class Task: Object {
    // 管理用ID　プライマリーキー
    dynamic var id = 0
    
//タイトル
dynamic var title = ""
    
//カテゴリ
dynamic var category = ""

//内容
dynamic var contents = ""

//日時
dynamic var date = NSDate()

/**
idをプライマリーキーとして設定
*/

override static func primaryKey() ->String? {
return "id"
}
}
