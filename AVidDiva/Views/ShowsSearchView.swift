//
//  ShowsView.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 11/10/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import SwiftUI

struct ShowsSearchView: View {
    @ObservedObject var showsViewModel = ShowsSearchViewModel()
    @State var searchingForShows = false
    @State var titleText: String = ""
    var body: some View {
        NavigationView {
            VStack {
                if searchingForShows {
                    HStack() {
                        Button("Back", action: {
                            self.showsViewModel.showSubscribedShows()
                            self.searchingForShows = false
                        })
                        TextField("TV Show Title", text: $titleText).textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.trailing)
                        Button("Search", action: {
                            self.showsViewModel.queryShows(self.titleText)
                        })
                    }.padding()
                }
                
                List(showsViewModel.showSearchResults) { show in
                    if self.searchingForShows {
                        ShowRow(showsViewModel: self.showsViewModel, show: show, searchingForShows: true)
                    } else {
                        NavigationLink(destination: ShowEpisodesView(showId: show.id)) {
                            ShowRow(showsViewModel: self.showsViewModel, show: show, searchingForShows: false)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("My Shows"), displayMode: .inline)
            .navigationBarItems(trailing:
                Button("Add", action: {
                        self.showsViewModel.clearShows()
                        self.searchingForShows = true
                       }))
        }.onAppear() {
            self.showsViewModel.querySubscribedShows()
        }
    }
}

struct ShowsSearchView_Previews: PreviewProvider {
    static var previews: some View {
        let view = ShowsSearchView()
        view.showsViewModel.showSearchResults.append(previewShow1)
        view.showsViewModel.showSearchResults.append(previewShow2)
        return view
    }
}

let previewShow1 = TVMazeShow(id: 210, name: "Doctor Who", premiered: "2005-03-26", officialSite: "http://www.bbc.co.uk/programmes/b006q2x0", image: TVMazeImage(medium: "http://static.tvmaze.com/uploads/images/medium_portrait/161/404447.jpg"), summary: "<p>Adventures across time and space with the time travelling alien and companions.</p>", updated: 0)
let previewShow2 = TVMazeShow(id: 1577473, name: "The Mandalorian", premiered: "2019-11-12", officialSite: nil, image: nil, summary: "<p>A Mandalorian bounty hunter tracks a target for a well-paying client.</p>", updated: 0)
