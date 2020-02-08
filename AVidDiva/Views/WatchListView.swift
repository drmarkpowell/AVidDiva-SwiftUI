//
//  WatchListView.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/28/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct WatchListView: View {
    @ObservedObject var watchListViewModel = WatchListViewModel()
    
    var body: some View {
        List {
            ForEach(watchListViewModel.showNames, id: \.self) { section in
                Section(header: Text(section)) {
                    return ForEach(self.watchListViewModel.episodes[section]!, id: \.self) { episode in
                        EpisodeRow(episodeViewModel: EpisodeViewModel(episode: episode))
                    }
                }
            }
        }.onAppear() {
            self.watchListViewModel.queryUnwatchedEpisodes()
        }
    }
}

struct WatchListView_Previews: PreviewProvider {
    static var previews: some View {
        let view = WatchListView()
        return view
    }
}
