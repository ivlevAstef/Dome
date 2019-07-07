//
//  LockUnlockState.swift
//  Dome
//
//  Created by Ивлев Александр on 07/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//

import Foundation


// Проверяет всякие временные рамки + геопозицию, дабы понять в каком сейчас состоянии пользователь
class LockUnlockState
{

    private(set) var locked: Bool = false {
        didSet {
            if locked != oldValue {
                updateHandler?(locked)
            }
        }
    }

    private var updateHandler: ((_ locked: Bool) -> Void)?

    init() {
        testUpdate()
    }

    func subscribe(on update: @escaping (_ locked: Bool) -> Void) {
        self.updateHandler = update
    }

    private func testUpdate() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 40.0) { [weak self] in
            if let self = self {
                self.locked = !self.locked
                self.testUpdate()
            }
        }
    }
}
