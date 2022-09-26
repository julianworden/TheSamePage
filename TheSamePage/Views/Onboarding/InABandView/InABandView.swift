//
//  InABandView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/21/22.
//

import SwiftUI

struct InABandView: View {
    @Binding var userIsOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 50) {
            Text("If your band is already on The Same Page, the admin of your band's page must invite you to join the band.")
            
            NavigationLink {
                BandSearchView()
            } label: {
                Text("Tap here to search for your band and confirm they're on The Same Page")
            }
            
            NavigationLink {
                AddEditBandView(userIsOnboarding: $userIsOnboarding, band: nil)
            } label: {
                Text(", tap here to get your band on The Same Page")
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct InABandView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            InABandView(userIsOnboarding: .constant(true))
        }
    }
}
