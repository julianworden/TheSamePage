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
        let config = Configuration(
            nodes: [Node(host: TypesenseConstants.host, port: TypesenseConstants.port, nodeProtocol: TypesenseConstants.nodeProtocol)],
            apiKey: TypesenseConstants.apiKey
        )

        return Client(config: config)
    }
}
