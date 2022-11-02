//
//  ShowLocationTab.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import MapKit
import SwiftUI

struct ShowLocationTab: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    // This is here instead of in viewModel to avoid "Publishing changes within view updates" runtime error
    @State private var showRegion: MKCoordinateRegion
    
    init(show: Show, viewModel: ShowDetailsViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
        self.showRegion = show.region
    }
    
    var body: some View {
        let show = viewModel.show
        
        VStack {
            if show.addressIsVisibleToUser {
                VStack {
                    Map(coordinateRegion: $showRegion, annotationItems: viewModel.mapAnnotations) {
                        MapMarker(coordinate: $0.coordinate)
                    }
                    .frame(height: 150)
                }
            }
            
            HStack {
                if show.addressIsVisibleToUser {
                    Text(show.address)
                } else {
                    Text("This show is taking place at a private address.")
                        .italic()
                }
                
                Spacer()
                
                VStack {
                    if show.addressIsVisibleToUser {
                        Button {
                            viewModel.showDirectionsInMaps()
                        } label: {
                            Label("Get Directions", systemImage: "map")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    if let showDistanceFromUser = show.distanceFromUser {
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
        ShowLocationTab(show: Show.example, viewModel: ShowDetailsViewModel(show: Show.example))
    }
}