//
//  EpisodeRow.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/29/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct EpisodeRow: View {
    var showsViewModel: EpisodesViewModel
    var episode: TVMazeEpisode
    
    var body: some View {
        Text(episode.name ?? "No name")
    }
}
