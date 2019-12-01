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
                            self.episodeViewModel.toggle()
                            })
                    {
                        Image((self.episodeViewModel.episode.watched == true) ? "checked" : "unchecked")
                        .resizable()
                        .frame(width: 40, height: 40, alignment: .center)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                Text(self.episodeViewModel.episode.getSummary())
                    .font(.caption)
                    .frame(height: self.textHeight, alignment: .leading)
                    .onTapGesture {
                        self.textHeight = self.textHeight == nil ? 60 : nil
                    }
            }
        }
    }
}
