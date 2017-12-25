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
let lastUpdated = "last-updated"

class ViewController: UIViewController {

	@IBOutlet var updateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
		updateHosts()
    }

	func updateHosts() {
		if let date = UserDefaults.standard.object(forKey: lastUpdated) as? Date, date > Date().addingTimeInterval(-12 * 60 * 60) {
			let numberOfDomains = (try? readHosts())?.count
			self.updateLabels(date: date, numberOfDomains: numberOfDomains)
			return
		}
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
			let date = (response.allHeaderFields["Last-Modified"] as? String).flatMap(parseRFC1123)

			try! self.replaceHostsFile(with: location, date: date)
			}.resume()
	}

	func replaceHostsFile(with location: URL, date: Date?) throws {
		let hostsFile = hostsFileLocation()
		try FileManager.default.replaceItem(at: hostsFile, withItemAt: location, backupItemName: nil, resultingItemURL: nil)
		let hosts = try readHosts()

		DispatchQueue.main.async {
			UserDefaults.standard.set(date, forKey: lastUpdated)
			self.updateLabels(date: date, numberOfDomains: hosts.count)
		}

		SFContentBlockerManager.reloadContentBlocker(withIdentifier: contentBlockerIdentifier) { error in
			guard let error = error else { return }
			print(error.localizedDescription)
		}
	}

	func updateLabels(date: Date?, numberOfDomains: Int?) {
		let format = DateFormatter()
		format.dateFormat = "yyyy-MM-dd"
		let version = date.map(format.string) ?? "unknown"

		if let numberOfDomains = numberOfDomains {
			let n = NumberFormatter.localizedString(from: NSNumber(value: numberOfDomains), number: NumberFormatter.Style.decimal)
			self.updateLabel.text = "\(n) sites included.\nThe version of the host list is \(version)."
		} else {
			self.updateLabel.text = "The version of the host list is \(version)."
		}
	}

	@IBAction func moreInformation() {
		UIApplication.shared.open(URL(string: "https://https4all.org/")!)
	}

	@IBAction func donate() {
		UIApplication.shared.open(URL(string: "https://supporters.eff.org/donate")!)
	}
}

func parseRFC1123(_ string: String) -> Date? {
	let dateFormat = DateFormatter()
	dateFormat.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
	return dateFormat.date(from: string)
}
