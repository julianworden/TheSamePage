//
//  ShowSearchResultsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import SwiftUI
import Typesense

struct ShowSearchResultsList: View {
    @Environment(\.isSearching) var isSearching
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        Group {
            switch viewModel.viewState {
            case .dataLoaded:
                ScrollView {
                    VStack(spacing: UiConstants.listRowSpacing) {
                        ForEach(viewModel.fetchedShows, id: \.document) { result in
                            let show = result.document!
                            
                            NavigationLink {
                                ShowDetailsView(show: show)
                            } label: {
                                SearchResultRow(show: show)
                            }
                            .tint(.primary)

                            Divider()
                        }
                    }
                }
                
            case .dataNotFound:
                NoDataFoundMessage(message: "No results.")
                
            case .error, .displayingView:
                EmptyView()
                
            default:
                ErrorMessage(message: "Invalid viewState")
            }
        }
        .onChange(of: viewModel.queryText) { _ in
            Task {
                await viewModel.fetchShows()
            }
        }
        .onChange(of: isSearching) { _ in
            viewModel.isSearching.toggle()
        }
    }
}

struct ShowSearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        ShowSearchResultsList(viewModel: SearchViewModel())
    }
}
