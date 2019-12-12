//
//  EpisodeRow.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/29/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct EpisodeRow: View {
    @ObservedObject var episodeViewModel: EpisodeViewModel
    @State var textHeight: CGFloat? = 60
    
    func action(_ long: Bool) {
        self.episodeViewModel.toggleWatched(long)
    }
    
    var body: some View {
       HStack(alignment: .center, spacing: 20) {
        ShowImage(urlPath: self.episodeViewModel.episode.image?.medium ?? "")
                .frame(alignment: .center)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(self.episodeViewModel.episode.name ?? "No name")
                            .font(.headline)
                        Text(self.episodeViewModel.episode.subtitle())
                            .font(.subheadline)
                    }
                    Spacer()
                    Button(action:{
                            })
                    {
                        Image((self.episodeViewModel.episode.watched == true) ? "checked" : "unchecked")
                        .resizable()
                        .onTapGesture {
                            self.action(false)
                        }
                        .onLongPressGesture(minimumDuration: 0.1) {
                            self.action(true)
                        }
                        .frame(width: 40, height: 40, alignment: .center)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                Text(self.episodeViewModel.episode.getSummary())
                    .font(.caption)
                    .frame(height: self.textHeight, alignment: .leading)
//                    .animation(.easeInOut(duration: 0.5)) //TODO this doesn't work well because the List container snaps to its new size instantly even though the text frame height is animating smoothly.
                    .onTapGesture {
                        self.textHeight = self.textHeight == nil ? 60 : nil
                    }
            }
        }
    }
}
