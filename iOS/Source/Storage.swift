//
//  LocalStorage.swift
//  Dome
//
//  Created by Ивлев Александр on 06/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//

import Foundation

class Storage
{

    private static let serverURLKey: String = "Storage_serverURL"
    private static let uuidKey: String = "Storage_UUID"

    var serverURL: URL?
//    {
//        get {
//            return UserDefaults.standard.url(forKey: Storage.serverURLKey)
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: Storage.serverURLKey)
//            UserDefaults.standard.synchronize()
//        }
//    }

    var uuid: String
    {
        if let value = UserDefaults.standard.string(forKey: Storage.uuidKey) {
            return value
        }

        let value = UUID().uuidString
        UserDefaults.standard.set(value, forKey: Storage.uuidKey)
        UserDefaults.standard.synchronize()

        return value
    }

    init() {

    }




}
