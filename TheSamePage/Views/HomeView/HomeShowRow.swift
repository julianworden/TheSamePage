//
//  HomeShowRow.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/26/22.
//

import SwiftUI

struct HomeShowRow: View {    
    let show: Show
    
    var body: some View {
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
                                Image("alcohol")
                                    .smallIconStyle()
                            }
                            
                            if show.hasFood {
                                Image("forkAndKnife")
                                    .smallIconStyle()
                            }
                            
                            if show.is21Plus {
                                Image(systemName: "21.circle")
                                    .smallIconStyle()
                            }
                        }
                    }
                }
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                if show.loggedInUserIsShowHost {
                    VStack {
                        Spacer()
                        
                        Text("You're hosting")
                    }
                }
            }
        }
    }
}

struct HomeShowRow_Previews: PreviewProvider {
    static var previews: some View {
        HomeShowRow(show: Show.example)
    }
}
