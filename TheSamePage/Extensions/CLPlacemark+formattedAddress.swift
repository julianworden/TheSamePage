//
//  CLPlacemark+formattedAddress.swift
//  AddressBook
//
//  Created by Julian Worden on 8/10/22.
//

import Contacts
import CoreLocation
import Foundation

extension CLPlacemark {
    var formattedAddress: String? {
        guard let postalAddress = postalAddress else { return nil }

        let formatter = CNPostalAddressFormatter()
        return formatter.string(from: postalAddress)
    }
}
