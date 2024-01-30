//
//  SwiftUIView.swift
//  
//
//  Created by Mateus Rodrigues on 29/01/24.
//

import SwiftUI

struct SwiftUIView: View {

    @State private var count = 0

    var body: some View {
        VStack {
            Text("Hello, World!")
                .padding()
            Color.red
                .frame(width: 200, height: 200)
        }
        .onAppear {

        }
    }
    
}

#Preview {
    SwiftUIView()
}
