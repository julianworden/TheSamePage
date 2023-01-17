//
//  BandSearchResultsList.swift
//  TheSamePage
//
//  Created by Julian Worden on 10/4/22.
//

import SwiftUI
import Typesense

struct BandSearchResultsList: View {
    @Environment(\.isSearching) var isSearching
    
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        Group {            
            switch viewModel.viewState {
            case .dataLoaded:
                ScrollView {
                    VStack(spacing: UiConstants.listRowSpacing) {
                        ForEach(viewModel.fetchedBands, id: \.document) { result in
                            let band = result.document!
                            
                            NavigationLink {
                                BandProfileView(band: band)
                            } label: {
                                SearchResultRow(band: band)
                            }
                            .tint(.primary)
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
                await viewModel.fetchBands()
            }
        }
        .onChange(of: isSearching) { _ in
            viewModel.isSearching.toggle()
        }
    }
}

struct BandSearchResultsList_Previews: PreviewProvider {
    static var previews: some View {
        BandSearchResultsList(viewModel: SearchViewModel())
    }
}
