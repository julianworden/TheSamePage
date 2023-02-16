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
        if let show = viewModel.show {
            // The first 3 rows are laid out like this because they do not iterate through an array, so they
            // harder to put into a reusable view
            VStack(spacing: UiConstants.listRowSpacing) {
                if let showDescription = show.description {
                    ListRowElements(
                        title: showDescription,
                        iconName: "notepad",
                        iconIsSfSymbol: false
                    )
                }

                if let showFormattedTicketPrice = show.formattedTicketPrice,
                   !show.isFree {
                    ListRowElements(
                        title: "Tickets are \(showFormattedTicketPrice) each",
                        iconName: "money",
                        iconIsSfSymbol: false
                    )
                }

                if show.isFree {
                    ListRowElements(
                        title: "Admission is free",
                        iconName: "money",
                        iconIsSfSymbol: false
                    )
                }

                if let showMinimumRequiredTicketsSold = show.minimumRequiredTicketsSold,
                   show.ticketSalesAreRequired,
                   !show.isFree {
                    ListRowElements(
                        title: "Ticket sales are required",
                        subtitle: "You must sell at least \(showMinimumRequiredTicketsSold) tickets",
                        iconName: "ticket",
                        iconIsSfSymbol: false
                    )
                }

                if show.hasBar {
                    ListRowElements(
                        title: "Drinks will be served",
                        iconName: "alcohol",
                        iconIsSfSymbol: false
                    )
                }

                if show.hasFood {
                    ListRowElements(
                        title: "Food will be served",
                        iconName: "forkAndKnife",
                        iconIsSfSymbol: false
                    )
                }

                if show.is21Plus {
                    ListRowElements(
                        title: "21+ only",
                        subtitle: "Don't forget your ID!",
                        iconName: "id",
                        iconIsSfSymbol: false
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ShowDetailsList_Previews: PreviewProvider {
    static var previews: some View {
        ShowDetailsList(viewModel: ShowDetailsViewModel(show: Show.example))
    }
}
