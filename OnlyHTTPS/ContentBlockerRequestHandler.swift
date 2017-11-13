//
//  ContentBlockerRequestHandler.swift
//  OnlyHTTPS
//
//  Created by Bouke van der Bijl on 01/11/2017.
//  Copyright © 2017 Bouke van der Bijl. All rights reserved.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        
        context.completeRequest(returningItems: [
			read("blockerList"),
			read("blockerList-mixedcontent"),
			], completionHandler: nil)
    }

	func read(_ file: String) -> NSExtensionItem {
		let attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: file, withExtension: "json"))!

		let item = NSExtensionItem()
		item.attachments = [attachment]
		return item
	}
    
}
