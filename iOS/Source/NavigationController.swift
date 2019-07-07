//
//  NavigationController.swift
//  Dome
//
//  Created by Ивлев Александр on 06/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//

import UIKit

class NavigatrionController: UINavigationController
{

    internal var storage: Storage?
    internal var network: Network?

    init() {
        super.init(nibName: nil, bundle: nil)

        self.setNavigationBarHidden(true, animated: false)
    }

    func activate()
    {
        guard let storage = self.storage else {
            fatalError("setup storage")
        }

        if nil == storage.serverURL {
            let vc = AuthenticateViewController()
            vc.storage = storage
            vc.network = network

            vc.finishHandler = { [weak self] qrCode in
                self?.saveQRCode(qrCode)
                // В идеале после сохранения все будет сохранено в хранилище
                self?.activate()
            }

            self.setViewControllers([vc], animated: false)
        } else {
            let vc = InformationViewController()
            vc.storage = storage
            vc.network = network

            self.setViewControllers([vc], animated: false)
        }
    }

    private func saveQRCode(_ qrCode: String) {
        self.storage?.serverURL = URL(string: qrCode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
