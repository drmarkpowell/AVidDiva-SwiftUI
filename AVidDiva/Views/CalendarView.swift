//
//  CalendarView.swift
//  AVidDiva
//
//  Created by Powell, Mark W (172D) on 11/29/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var calendarViewModel = CalendarViewModel()
    
    var body: some View {
        List {
            ForEach(calendarViewModel.times, id: \.self) { section in
                Section(header: Text(section)) {
                    return ForEach(self.calendarViewModel.episodes[section]!, id: \.self) { episode in
                        EpisodeRow(episodeViewModel: EpisodeViewModel(episode: episode))
                    }
                }
            }
        }.onAppear() {
            self.calendarViewModel.queryUnwatchedEpisodes()
        }
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let view = CalendarView()
        return view
    }
}
