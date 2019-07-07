//
//  Network.swift
//  Dome
//
//  Created by Ивлев Александр on 06/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//

import Starscream

class Network
{
    enum State: Int {
        case disconnected
        case unknown
        case created
        case connected
        case waitToken
        case waitRegister
        case waitInfo
        case registered
    }

    var storage: Storage?

    var showURLHandler: ((URL) -> Void)?
    var stateChanged: ((State) -> Void)?
    var infoChanged: ((_ info: [String: Any]) -> Void)?
    var lockState: ((_ locked: Bool) -> Void)?

    var locked: Bool { return CheckHaveCamera.checkHaveCamera() }

    var sessionId: Int64?
    private var sessionToken: String?

    private var socket: WebSocket?
    private var state: State = .unknown {
        didSet {
            if state != oldValue {
                processStateChanged(from: oldValue, to: state)
                stateChanged?(state)
            }
        }
    }

    init() {

    }

    private func url(scheme: String, removePort: Bool = false, additionalPath: String = "") -> URL {
        guard let serverURL = storage?.serverURL else {
            fatalError("Can't found server url")
        }

        guard var components = URLComponents(url: serverURL, resolvingAgainstBaseURL: false) else {
            fatalError("Can't parse url")
        }
        components.scheme = scheme
        components.path = components.path + additionalPath

        if removePort {
            components.port = nil
        }

        guard let url = components.url else {
            fatalError("Can't make url with scheme: \(scheme)")
        }

        return url
    }

    func authenticate() {
        let socketURL = url(scheme: "ws")

        print("socket url \(socketURL)")
        let socket = WebSocket(url: socketURL)
        socket.request.timeoutInterval = 5.0
        self.socket = socket

        subscribeOnSocketEvents()

        state = .created
        socket.connect()
    }

    private func subscribeOnSocketEvents() {
        guard let socket = self.socket else {
            fatalError("Can't found socket")
        }

        socket.onConnect = { [weak self] in
            self?.state = .connected
            print("websocket is connected")
        }
        socket.onDisconnect = { [weak self] (error: Error?) in
            self?.state = .disconnected
            print("websocket is disconnected: \(error?.localizedDescription)")
        }
        socket.onText = { [weak self] (text: String) in
            print("got some text: \(text)")
            self?.processServerText(text)
        }
        socket.onData = { (data: Data) in
            print("got some data: \(data.count)")
        }

        subscribeOnFlagChanged { [weak self] locked in
            if let state = self?.state, state.rawValue >= State.registered.rawValue {
                self?.lockState?(locked)
            }
        }
    }

    private func processStateChanged(from: State, to: State) {
        switch (from, to) {
        case (_, .connected):
            let msg = "{ \"e\" : \"token\" }"
            socket?.write(string: msg)

            print("Send message: \(msg)")
            state = .waitToken

        case (_, .waitRegister):
            let vendorId = UIDevice.current.identifierForVendor?.uuidString ?? "undefined"
            let uuid = self.storage!.uuid

            let msg = "{\"e\":\"mobile\",\"imei\":\"\(vendorId)\",\"system\":\"ios\",\"genkeycode\":\"\(uuid)\"}"
            socket?.write(string: msg)

            print("Send message: \(msg)")
        default:
            break
        }
    }

    private func processServerText(_ text: String) {
        guard let dict = try? JSONSerialization.jsonObject(with: text.data(using: .utf8)!, options: []) as? [String: Any] else {
            return
        }

        if dict["e"] as? String == "info" {
            let info = [String: Any]()
            infoChanged?(info)
        }

        switch state {
        case .waitToken:
            if dict["e"] as? String == "token", let token = dict["m"] as? String {
                sessionToken = token
                state = .waitRegister
            }
        case .waitRegister:
            if dict["e"] as? String == "mobile", let id = dict["id"] as? Int64 {
                sessionId = id
                state = .waitInfo
            }
            fallthrough
        case .waitInfo:
            //if dict["e"] as? String == "info" {
                state = .registered
            //}
        default:
            break
        }
    }

}


// Код тут написан на костылях так как у меня не оказалось прав на создание нужных сертов:
// Инструкция о том как нормально сделать https://medium.com/developerinsider/how-to-create-a-verified-ios-mobile-device-management-mdm-profile-9d6739b92cc1
// Такая технология позволяет обновлять конфиги без необходимости переустановки,
// и узнать нормально состояния установлен или нет (можно посмотреть тут инфу:
// https://developer.apple.com/business/documentation/MDM-Protocol-Reference.pdf
// в секции MDM Check-in Protocol
extension Network
{
    func lock() {
        let fileURL = url(scheme: "https", removePort: true, additionalPath: "/ios/LockConfig.mobileconfig")
        self.showURLHandler?(fileURL)
    }

    func unlock() {
        let fileURL = url(scheme: "https", removePort: true, additionalPath: "/ios/UnlockConfig.mobileconfig")
        self.showURLHandler?(fileURL)
    }

    private func waitConfig(flag: Bool, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else {
                return
            }

            if flag == CheckHaveCamera.checkHaveCamera() {
                completion()
            } else {
                self.waitConfig(flag: flag, completion: completion)
            }
        }
    }

    private func subscribeOnFlagChanged(handler: @escaping (_ locked: Bool) -> Void) {
        let currentFlag: Bool = CheckHaveCamera.checkHaveCamera()

        waitConfig(flag: !currentFlag) { [weak self] in
            handler(!currentFlag)
            self?.subscribeOnFlagChanged(handler: handler)
        }
    }
}
