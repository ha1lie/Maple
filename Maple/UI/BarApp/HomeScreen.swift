//
//  ContentView.swift
//  Maple
//
//  Created by Hallie on 4/2/22.
//

import SwiftUI

/// Status bar app container view
struct HomeScreen: View {
    @State var selectedLeaf: Leaf? = nil
    
    var body: some View {
        HStack {
            LeafList(selectedLeaf: self.$selectedLeaf)
                .animation(.easeInOut, value: self.selectedLeaf)
                .if(self.selectedLeaf != nil) { v in
                    v.frame(width: 0)
                        .opacity(0)
                }
            LeafDetailView(selectedLeaf: self.$selectedLeaf)
                .animation(.easeInOut, value: self.selectedLeaf)
                .if(self.selectedLeaf == nil) { v in
                    v.frame(width: 0)
                        .opacity(0)
                }
        }
    }
}
