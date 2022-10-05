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
        let config = Configuration(nodes: [Node(host: "2jclf5b8r1nypvtwp-1.a1.typesense.net", port: "443", nodeProtocol: "https")], apiKey: "jDxoU4Vpi1lekRJ77gS0KFAC3sCi3Ens")
        return Client(config: config)
    }
}
