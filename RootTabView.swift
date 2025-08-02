//
//  RootTabView.swift
//  nmdpMatchMeSwiftUI
//
//  Created by Steven Anderson on 2025-06-15.
//

import SwiftUI

struct RootTabView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        TabView {
            NavigationView { LoginView() }
                .tabItem { Label("Home", systemImage: "house") }
            
            NavigationView { TiktokFeedView() }
                .tabItem { Label("Feed", systemImage: "play.rectangle") }
            
            NavigationView { AiChatView() }
                .tabItem { Label("Ask AI", systemImage: "brain.head.profile") }
            
            NavigationView { MatchMap() }
                .tabItem { Label("Map", systemImage: "map")}
            
            NavigationView { HlaResultView() }
                .tabItem { Label("HLA Results", systemImage: "square.and.arrow.up") }
        }
        .sheet(isPresented: $appDelegate.kitReceivedAlertIsPresented) {
            KitReceivedConfirmationView()
        }
        .sheet(isPresented: $appDelegate.hlaResultsIsPresented) {
            HlaResultView()
        }
        .sheet(isPresented: $appDelegate.matchAlertIsPresented) {
            MatchConfirmationView()
        }
    }
}

