//
//  SafariOpenURLHelper.swift
//  Dome
//
//  Created by Ивлев Александр on 06/07/2019.
//  Copyright © 2019 SIA. All rights reserved.
//

import SafariServices

public class SafariOpenURLHelper {

    static func show(on navigationController: UINavigationController, url: URL, animated: Bool) {
        SafariViewControllerAdapter().show(on: navigationController, url: url, animated: animated)
    }
}

private class SafariViewControllerAdapter: NSObject, SFSafariViewControllerDelegate {
    private var autoRetain: SafariViewControllerAdapter?

    fileprivate func show(on navigationController: UINavigationController, url: URL, animated: Bool) {
        self.autoRetain = self

        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self

        navigationController.present(safariVC, animated: animated, completion: nil)
    }

    fileprivate func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        self.autoRetain = nil
        controller.dismiss(animated: true, completion: nil)
    }
}
