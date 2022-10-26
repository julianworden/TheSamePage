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
        VStack(spacing: 0) {
            let show = viewModel.show
            // TODO: Make this row a NavigationLink?
            SmallListRow(title: "Hosted by \(show.host)", subtitle: nil, iconName: "user", displayChevron: false)
            
            if let showFormattedTicketPrice = show.formattedTicketPrice {
                SmallListRow(title: "Tickets are \(showFormattedTicketPrice) each", subtitle: nil, iconName: "money", displayChevron: false)
            }
            
            if let showMinimumRequiredTicketsSold = show.minimumRequiredTicketsSold,
               show.ticketSalesAreRequired {
                SmallListRow(title: "Ticket sales are required", subtitle: "You must sell at least \(showMinimumRequiredTicketsSold) tickets.", iconName: "ticket", displayChevron: false)
            }
            
            if show.hasBar {
                SmallListRow(title: "Drinks will be served", subtitle: nil, iconName: "alcohol", displayChevron: false)
            }
            
            if show.hasFood {
                SmallListRow(title: "Food will be served", subtitle: nil, iconName: "forkAndKnife", displayChevron: false)
            }
            
            if show.is21Plus {
                SmallListRow(title: "21+ only", subtitle: "Don't forget your ID!", iconName: "id", displayChevron: false)
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
