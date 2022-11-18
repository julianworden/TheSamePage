//
//  LargeListRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import SwiftUI

struct HostedShowRow: View {
    @ObservedObject var viewModel: MyShowsViewModel
    
    let index: Int
    
    init(index: Int, viewModel: MyShowsViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
        self.index = index
    }
    
    var body: some View {
        if !viewModel.hostedShows.isEmpty {
            let show = viewModel.hostedShows[index]
            
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
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
}

struct LargeListRow_Previews: PreviewProvider {
    static var previews: some View {
        HostedShowRow(index: 1, viewModel: MyShowsViewModel())
    }
}
