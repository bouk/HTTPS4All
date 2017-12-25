//
//  SiteTableViewController.swift
//  HTTPS4All
//
//  Created by Bouke van der Bijl on 24/12/2017.
//  Copyright © 2017 Bouke van der Bijl. All rights reserved.
//

import UIKit
import HTTPS4AllShared

typealias HostMap = Dictionary<Character, ArraySlice<Substring>>

func hostsToMap(hosts: [Substring]) -> HostMap {
	var iter = hosts.enumerated().makeIterator()
	var currentFirst = iter.next()!.1.first!
	var currentStart = 0
	var result: HostMap = [:]
	for (i, host) in iter {
		let c = host.first!
		if c == currentFirst {
			continue
		}
		result[currentFirst] = hosts[currentStart..<i]
		currentFirst = c
		currentStart = i
	}
	result[currentFirst] = hosts[currentStart...]
	return result
}

func getHosts() -> HostMap {
	if let hosts = try? readHosts() {
		return hostsToMap(hosts: hosts)
	} else {
		return [:]
	}
}

class SiteTableViewController: UITableViewController {

	lazy var hosts: HostMap = getHosts()
	lazy var keys: [String] = hosts.keys.sorted().map { c in String(c) }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return hosts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hosts[keys[section].first!]!.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SiteCell", for: indexPath)

		let k = keys[indexPath.section].first!
		let h = hosts[k]!
		cell.textLabel?.text = String(h[h.startIndex + indexPath.row])
        return cell
    }

	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return keys[section]
	}

	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return keys
	}

	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return keys.index(of: title)!
	}
}
