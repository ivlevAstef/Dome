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

    private var timeInterval: (from: Date, to: Date)?

    private var testTime: Double = 20.0

    init() {
        updater()
    }

    func subscribe(on update: @escaping (_ locked: Bool) -> Void) {
        self.updateHandler = update
    }

    func setPolygon() {

    }

    func removePolygon() {
        
    }

    func setTimeInterval(from: Date, to: Date) {
        self.timeInterval = (from, to)
    }

    func removeTimeInterval() {
        self.timeInterval = nil
    }

    private func updater() {
        // Тут код меняется на проверку что текущая дата (которая синхронизуется с сервером) входит в интервал
        // Также тут будет проверка что есть выход за пределы полигона
        // Для этого применяется информация о геопозиции
        // Полигоны планировалось хранить в виде массива двух точек - начало линии, конец линии.
        // Для проверки вхождения точки будет использоваться простой алгоритм - пускай луч из точки.
        // Если четкое количество перечений или 0 - то мы не в области, если не четное то внутри области.
        DispatchQueue.main.asyncAfter(deadline: .now() + testTime) { [weak self] in
            if let self = self {
                self.testTime += 10.0
                self.locked = !self.locked
                self.updater()
            }
        }
    }

    private func checkTimeInterval() {
        guard let (from, to) = self.timeInterval else {
            return
        }

        if from < Date() && Date() < to {
            self.locked = true
        } else {
            self.locked = false
        }
    }
}
