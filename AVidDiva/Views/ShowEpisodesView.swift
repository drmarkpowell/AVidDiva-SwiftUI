//
//  ShowEpisodesView.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 11/24/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct ShowEpisodesView: View {
    @ObservedObject var episodesViewModel: EpisodesViewModel
    
    init(_ episodesViewModel: EpisodesViewModel) {
        self.episodesViewModel = episodesViewModel
    }
    
    var body: some View {
        List(episodesViewModel.episodes) { episode in
            HStack(alignment: .center, spacing: 20) {
                ShowImage(urlPath: episode.image?.medium ?? "")
                    .frame(alignment: .center)
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(episode.name ?? "No name")
                                .font(.headline)
                            Text(episode.subtitle())
                                .font(.subheadline)
                        }
                        Spacer()
                        Image((episode.watched == true) ? "checked" : "unchecked")
                            .resizable()
                            .frame(width: 40, height: 40, alignment: .center)
                    }
                    ScrollView() {
                        Text(episode.getSummary())
                            .font(.caption)
                    }
                    .frame(height: 60, alignment: .leading)
                }
            }
        }
    }
}

struct ShowEpisodesView_Previews: PreviewProvider {
    static var previews: some View {
      
        let view = ShowEpisodesView(EpisodesViewModel(showId: -1))
        view.episodesViewModel.episodes.append(episode1)
        view.episodesViewModel.episodes.append(episode2)
        return view
    }
}

let episode1 = TVMazeEpisode(id: 1577473, showId: 38963, name: "Chapter 1", season: 1, number: 1, airdate: "2019-11-12", airtime: "", image: TVMazeImage(medium: "http://static.tvmaze.com/uploads/images/medium_landscape/222/556622.jpg"), summary: "<p>A Mandalorian bounty hunter tracks a target for a well-paying client.</p>", watched: true)
let episode2 = TVMazeEpisode(id: 1740391, showId: 38963, name: "Chapter 2: The Child", season: 1, number: 2, airdate: "2019-11-15", airtime: "", image: TVMazeImage(medium: "http://static.tvmaze.com…landscape/224/560488.jpg"), summary:     "<p>Target in-hand, the Mandalorian must now contend with scavengers.</p>", watched: false)
