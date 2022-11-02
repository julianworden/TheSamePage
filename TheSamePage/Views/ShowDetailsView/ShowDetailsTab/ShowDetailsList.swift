//
//  ShowDetailsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/10/22.
//

import SwiftUI

struct ShowDetailsList: View {
    @ObservedObject var viewModel: ShowDetailsViewModel
    
    var body: some View {
        // The first 3 rows are laid out like this because they do not iterate through an array, so they
        // harder to put into a reusable view
        VStack(spacing: 12) {
            let show = viewModel.show
            
            if let showDescription = show.description {
                HStack(alignment: .top, spacing: 10) {
                    Image("notepad")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    
                    Text(showDescription)
                        .padding(.bottom, 5)
                    
                    Spacer()
                }
            }
            
            HStack(spacing: 10) {
                Image("user")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text("Hosted by \(show.host)")
                
                Spacer()
            }
            
            if let showFormattedTicketPrice = show.formattedTicketPrice {
                HStack(spacing: 10) {
                    Image("money")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    Text("Tickets are \(showFormattedTicketPrice) each")
                    
                    Spacer()
                }
            }
            
            if let showMinimumRequiredTicketsSold = show.minimumRequiredTicketsSold,
               show.ticketSalesAreRequired {
                HStack(spacing: 10) {
                    Image("ticket")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                    
                    VStack(alignment: .leading) {
                        Text("Ticket sales are required")
                        
                        Text("You must sell at least \(showMinimumRequiredTicketsSold) tickets")
                            .font(.caption)
                    }
                    .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
            }
            
            if show.hasBar {
                ShowDetailsStaticRow(title: "Drinks will be served", subtitle: nil, iconName: "alcohol")
            }
            
            if show.hasFood {
                ShowDetailsStaticRow(title: "Food will be served", subtitle: nil, iconName: "forkAndKnife")
            }
            
            if show.is21Plus {
                ShowDetailsStaticRow(title: "21+ only", subtitle: "Don't forget your ID!", iconName: "id")
            }
        }
        .padding(.horizontal)
    }
}

struct ShowDetailsList_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
