//
//  HostedShow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/5/22.
//

import FirebaseFirestoreSwift
import Foundation

struct HostedShow: Identifiable {
    @DocumentID var id: String?
}
