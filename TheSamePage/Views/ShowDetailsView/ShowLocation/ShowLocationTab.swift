//
//  ShowLocationTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import MapKit
import SwiftUI

struct ShowLocationTab: View {
    @StateObject var viewModel: ShowLocationTabViewModel
    
    // This is here instead of in viewModel to avoid "Publishing changes within view updates" runtime error
    @State private var showRegion: MKCoordinateRegion
    
    init(show: Show) {
        self.showRegion = show.region
        
        _viewModel = StateObject(wrappedValue: ShowLocationTabViewModel(show: show))
    }
    
    var body: some View {
        VStack {
            if viewModel.addressIsVisibleToUser {
                VStack {
                    Map(coordinateRegion: $showRegion, annotationItems: viewModel.mapAnnotations) {
                        MapMarker(coordinate: $0.coordinate)
                    }
                    .frame(height: 150)
                }
            }
            
            HStack {
                if viewModel.addressIsVisibleToUser {
                    Text(viewModel.showAddress)
                } else {
                    Text("This show is taking place at a private address.")
                        .italic()
                }
                
                Spacer()
                
                VStack {
                    if viewModel.addressIsVisibleToUser {
                        Button {
                            viewModel.showDirectionsInMaps()
                        } label: {
                            Label("Get Directions", systemImage: "map")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if let showDistanceFromUser = viewModel.showDistanceFromUser {
                        Text("~\(showDistanceFromUser) away")
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ShowLocationTab_Previews: PreviewProvider {
    static var previews: some View {
        ShowLocationTab(show: Show.example)
    }
}
