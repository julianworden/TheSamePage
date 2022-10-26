//
//  HomeShowRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/26/22.
//

import SwiftUI

struct HomeShowRow: View {
    @StateObject var viewModel: HomeShowRowViewModel
    
    init(show: Show) {
        _viewModel = StateObject(wrappedValue: HomeShowRowViewModel(show: show))
    }
    
    var body: some View {
        let show = viewModel.show
        
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(show.name)
                        .font(.title3.bold())
                    
                    Text(show.venue)
                    
                    Text(show.formattedDate)
                    
                    if let showDescription = show.description {
                        Text(showDescription)
                            .lineLimit(2)
                            .font(.caption)
                    }
                    
                    if show.shouldDisplayIcons {
                        HStack {
                            if show.hasBar {
                                Image(systemName: "wineglass")
                            }
                            
                            if show.hasFood {
                                Image(systemName: "fork.knife")
                            }
                            
                            if show.is21Plus {
                                Image(systemName: "21.circle")
                            }
                        }
                        .imageScale(.small)
                    }
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
}

struct HomeShowRow_Previews: PreviewProvider {
    static var previews: some View {
        HomeShowRow(show: Show.example)
    }
}
