//
//  ContentBlockerRequestHandler.swift
//  OnlyHTTPS
//
//  Created by Bouke van der Bijl on 01/11/2017.
//  Copyright © 2017 Bouke van der Bijl. All rights reserved.
//

import HTTPS4AllShared
import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
		let hosts = try! readHosts()
		let rules = hostListToRules(hosts)
		let serialized = serialize(rules)
        context.completeRequest(returningItems: [serialized], completionHandler: nil)
    }

	private func hostListToRules<T: StringProtocol>(_ hosts: [T]) -> [[String: Any]] {
		return [
			["action": [
				"type": "make-https",
			], "trigger": [
				"url-filter": ".*",
				"if-domain": hosts,
			]],
		]
	}

	private func serialize(_ rules: [[String: Any]]) -> NSExtensionItem {
		let item = NSExtensionItem()
		let data = try! JSONSerialization.data(withJSONObject: rules)
		let attachment = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypeJSON as String)
		item.attachments = [attachment]
		return item
	}
}
