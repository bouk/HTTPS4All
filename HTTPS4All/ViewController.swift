//
//  ViewController.swift
//  HTTPS4All
//
//  Created by Bouke van der Bijl on 01/11/2017.
//  Copyright © 2017 Bouke van der Bijl. All rights reserved.
//

import HTTPS4AllShared
import SafariServices
import UIKit

let hostsURL = URL(string: "https://hosts.https4all.org/hosts.txt")!

class ViewController: UIViewController {

	@IBOutlet var updateLabel: UILabel!
	@IBOutlet var versionLabel: UILabel!
	var currentDate: Date? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
		updateHosts()
    }

	func updateHosts() {
		updateLabel.text = "Updating..."

		URLSession.shared.downloadTask(with: hostsURL) { location, response, error in
			if let error = error {
				DispatchQueue.main.async {
					self.updateLabel.text = "Failed to fetch update: \(error.localizedDescription)"
				}
				return
			}

			guard let response = response as? HTTPURLResponse else { return }
			guard response.statusCode == 200 else {
				DispatchQueue.main.async {
					self.updateLabel.text = "Failed to fetch update: \(response.statusCode)"
				}

				return
			}
			guard let location = location else { return }
			self.currentDate = (response.allHeaderFields["Last-Modified"] as? String).flatMap(parseRFC1123)

			try! self.replaceHostsFile(with: location)
			}.resume()
	}

	func replaceHostsFile(with location: URL) throws {
		let hostsFile = hostsFileLocation()
		try FileManager.default.replaceItem(at: hostsFile, withItemAt: location, backupItemName: nil, resultingItemURL: nil)
		let hosts = try readHosts()

		let n = NumberFormatter.localizedString(from: NSNumber(value: hosts.count), number: NumberFormatter.Style.decimal)
		DispatchQueue.main.async {
			self.updateLabel.text = "Updated! \(n) domains included."

			let format = DateFormatter()
			format.dateFormat = "yyyy-MM-dd"
			let version = self.currentDate.map(format.string) ?? "unknown"
			self.versionLabel.text = "Version: \(version)"
		}

		SFContentBlockerManager.reloadContentBlocker(withIdentifier: contentBlockerIdentifier) { error in
			guard let error = error else { return }
			print(error.localizedDescription)
		}
	}
}

func parseRFC1123(_ string: String) -> Date? {
	let dateFormat = DateFormatter()
	dateFormat.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
	return dateFormat.date(from: string)
}
