//
//  StoryView.swift
//  Smartastro
//
//  Created by AmineBj on 12/12/24.
//

import SwiftUI

struct StoryView: View {
    var images: [String] = ["image-1", "image-2", "image-3", "image-4", "image-5"]
    @ObservedObject var countTimer: CountTimer = CountTimer(items: 5, interval: 4.0)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Display the current image
                Image(self.images[Int(self.countTimer.progress)])
                    .resizable()
                    .edgesIgnoringSafeArea(.all)
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: nil, alignment: .center)
                
                // Progress Bar
                HStack(alignment: .center, spacing: 4) {
                    ForEach(self.images.indices, id: \.self) { index in
                        LoadingBar(progress: min(max(CGFloat(self.countTimer.progress) - CGFloat(index), 0.0), 1.0))
                            .frame(height: 2, alignment: .leading)
                            .transition(.opacity) // Optional smooth appearance
                    }
                }
                .padding()
                
                // Left and Right Tap Areas
                HStack(alignment: .center, spacing: 0) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut) {
                                self.countTimer.advancePage(by: -1)
                            }
                        }
                    Rectangle()
                        .foregroundColor(.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeOut) {
                                self.countTimer.advancePage(by: 1)
                            }
                        }
                }
            }
            .onAppear {
                self.countTimer.start()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
    }
}
