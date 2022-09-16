//
//  ProfileView.swift
//  TheSamePage
//
//  Created by Julian Worden on 9/15/22.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            VStack {
                SectionTitle(title: "Julian Worden")
                
                Image("profilePicture")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 158)
                
                SectionTitle(title: "Member of")
                
                ScrollView {
                    
                }
            }
            .navigationTitle("Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
