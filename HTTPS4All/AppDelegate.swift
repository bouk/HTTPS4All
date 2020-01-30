//
//  AppDelegate.swift
//  HTTPS4All
//
//  Created by Bouke van der Bijl on 01/11/2017.
//  Copyright © 2017 Bouke van der Bijl. All rights reserved.
//

import HTTPS4AllShared
import UIKit
import SafariServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var enableAlertController: UIAlertController?
	var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		checkContentBlockerState()

		SFContentBlockerManager.reloadContentBlocker(withIdentifier: contentBlockerIdentifier) { error in
			guard let error = error else { return }
			print(error.localizedDescription)
		}
        return true
    }

	func applicationWillEnterForeground(_ application: UIApplication) {
		checkContentBlockerState()
	}
}

extension AppDelegate {
	fileprivate func checkContentBlockerState() {
		SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: contentBlockerIdentifier) { (state, error) in
			if let state = state {
				DispatchQueue.main.async {
					if state.isEnabled {
						self.hideEnableAlert()
					} else {
						self.showEnableAlert()
					}
				}
			}
		}
	}

	private func showEnableAlert() {
		guard enableAlertController == nil else { return }
		let controller = createEnableAlert()
		enableAlertController = controller
		window?.rootViewController?.present(controller, animated: true)
	}

	private func hideEnableAlert() {
		guard enableAlertController != nil else { return }
		enableAlertController = nil
		window?.rootViewController?.dismiss(animated: true)
	}

	private func createEnableAlert() -> UIAlertController {
		return UIAlertController(title: "Enable Content Blocker", message: "Please open\nSettings → Safari → Content Blockers\nand enable HTTPS4All to get started", preferredStyle: .alert)
	}
}
