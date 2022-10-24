//
//  EditImageViewModel.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/23/22.
//

import Foundation
import UIKit.UIImage

class EditImageViewModel: ObservableObject {
    @Published var state = ViewState.dataLoaded
    
    let show: Show
    let imageUrl: String?
    
    init(show: Show) {
        self.show = show
        self.imageUrl = show.imageUrl
    }
    
    func updateShowImage(show: Show, withImage image: UIImage) async throws {
        try await DatabaseService.shared.updateShowImage(image: image, show: show)
    }
}
