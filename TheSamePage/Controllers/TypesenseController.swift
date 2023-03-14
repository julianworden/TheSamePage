//
//  TypesenseController.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import Foundation
import Typesense

final class TypesenseController: ObservableObject {
    static var client: Client {
        let config = Configuration(nodes: [Node(host: "hqftg6rxza8wb37sp-1.a1.typesense.net", port: "443", nodeProtocol: "https")], apiKey: "yXmJUEiW9MQy0qjJiGqO02JmcnbGEDhl")
        return Client(config: config)
    }
}
