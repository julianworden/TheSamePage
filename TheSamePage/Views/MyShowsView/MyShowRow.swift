//
//  LargeListRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/8/22.
//

import SwiftUI

struct MyShowRow: View {
    @ObservedObject var providedViewModel: MyShowsViewModel
    
    let index: Int
    
    init(index: Int, viewModel: MyShowsViewModel) {
        _providedViewModel = ObservedObject(initialValue: viewModel)
        self.index = index
    }
    
    var body: some View {
        let show = providedViewModel.hostedShows[index]
        
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(show.name)
                        .font(.title3.bold())
                    
                    Text(show.venue)
                    
                    Text(show.formattedDate)
                    
                    Text(show.description ?? "")
                        .lineLimit(2)
                        .font(.caption)
                    
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
                .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
}

struct LargeListRow_Previews: PreviewProvider {
    static var previews: some View {
        MyShowRow(index: 1, viewModel: MyShowsViewModel())
    }
}
