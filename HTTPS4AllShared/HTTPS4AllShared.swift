//
//  HTTPS4AllShared.swift
//  HTTPS4AllShared
//
//  Created by Bouke van der Bijl on 21/11/2017.
//  Copyright © 2017 Bouke van der Bijl. All rights reserved.
//

import Foundation

public let contentBlockerIdentifier = "co.bouk.HTTPSAllTheThings.OnlyHTTPS"
public let securityContainerIdentifier = "group.co.bouk.HTTPSAllTheThings"

public func hostsFileLocation() -> URL {
	return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: securityContainerIdentifier)!.appendingPathComponent("hosts.txt")
}

public func readHosts(_ location: URL = hostsFileLocation()) throws -> [Substring] {
	let data = try Data(contentsOf: location)
	let string = String(data: data, encoding: .utf8)!
	let lines = string.split(separator: "\n").filter { !$0.isEmpty && !$0.starts(with: "#") }
	return lines
}
