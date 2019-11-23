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
    @State var titleText: String = ""
    var body: some View {
        VStack {
            HStack() {
                TextField("TV Show Title", text: $titleText).textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.trailing)
                Button(action: {
                    self.showsViewModel.queryShows(self.titleText)
                }) {
                    Text("Search")
                }
            }.padding()
            
            List(showsViewModel.showSearchResults) { show in
                HStack(alignment: .center, spacing: 20) {
                    ShowImage(urlPath: show.image?.medium ?? "")
                    Text(show.name ?? "No name")
                    Spacer()
                    Button(action: {
                        CloudKitAPI.shared.addOrUpdateSubscription(show: show)
                    }) {
                        Text("Add")
                    }
                }
            }
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

let previewShow1 = TVMazeShow(id: 210, name: "Doctor Who", premiered: "2005-03-26", officialSite: "http://www.bbc.co.uk/programmes/b006q2x0", image: TVMazeImage(medium: "http://static.tvmaze.com/uploads/images/medium_portrait/161/404447.jpg"), summary: "<p>Adventures across time and space with the time travelling alien and companions.</p>")
let previewShow2 = TVMazeShow(id: 1577473, name: "The Mandalorian", premiered: "2019-11-12", officialSite: nil, image: nil, summary: "<p>A Mandalorian bounty hunter tracks a target for a well-paying client.</p>")
