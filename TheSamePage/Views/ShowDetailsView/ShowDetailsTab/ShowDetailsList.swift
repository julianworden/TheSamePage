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
        VStack(spacing: UiConstants.listRowSpacing) {
            let show = viewModel.show
            
            if let showDescription = show.description {
                ListRowElements(
                    title: showDescription,
                    iconName: "notepad"
                )
            }
            
            if let showFormattedTicketPrice = show.formattedTicketPrice,
               !show.isFree {
                ListRowElements(
                    title: "Tickets are \(showFormattedTicketPrice) each",
                    iconName: "money"
                )
            }
            
            if show.isFree {
                ListRowElements(
                    title: "Admission is free",
                    iconName: "money"
                )
            }
            
            if let showMinimumRequiredTicketsSold = show.minimumRequiredTicketsSold,
               show.ticketSalesAreRequired,
               !show.isFree {
                ListRowElements(
                    title: "Ticket sales are required",
                    subtitle: "You must sell at least \(showMinimumRequiredTicketsSold) tickets",
                    iconName: "ticket"
                )
            }
            
            if show.hasBar {
                ListRowElements(
                    title: "Drinks will be served",
                    iconName: "alcohol"
                )
            }
            
            if show.hasFood {
                ListRowElements(
                    title: "Food will be served",
                    iconName: "forkAndKnife"
                )
            }
            
            if show.is21Plus {
                ListRowElements(
                    title: "21+ only",
                    subtitle: "Don't forget your ID!",
                    iconName: "id"
                )
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
