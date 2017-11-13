//
//  AppDelegate.swift
//  HTTPS All The Things
//
//  Created by Bouke van der Bijl on 01/11/2017.
//  Copyright © 2017 Bouke van der Bijl. All rights reserved.
//

import UIKit
import SafariServices

public let ContentBlockerIdentifier = "co.bouk.HTTPSAllTheThings.OnlyHTTPS"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var enableAlertController: UIAlertController?
	var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		checkContentBlockerState()

		SFContentBlockerManager.reloadContentBlocker(withIdentifier: ContentBlockerIdentifier) { error in
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
		SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: ContentBlockerIdentifier) { (state, error) in
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
		return UIAlertController(title: "Enable Content Blocker", message: "Please open\nSettings → Safari → Content Blockers\nand enable HTTPS All The Things to get started", preferredStyle: .alert)
	}
}
