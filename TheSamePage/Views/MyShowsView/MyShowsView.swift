//
//  MyShowsView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct MyShowsView: View {
    var body: some View {
        NavigationView {
            VStack {
                SectionTitle(title: "You're Playing")
                
                ScrollView {
                    
                }
            }
            .navigationTitle("My Shows")
        }
    }
}

struct MyShowsView_Previews: PreviewProvider {
    static var previews: some View {
        MyShowsView()
    }
}
