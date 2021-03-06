
//
//  NetworkAPI.swift
//  AVidDiva
//
//  Created by Powell, Mark W (397M) on 10/27/19.
//  Copyright © 2019 Powellware. All rights reserved.
//

import Foundation
import Combine

public class NetworkAPI {

    static let shared = NetworkAPI()
    private init() { }

    private var getShowsCancellable: AnyCancellable?
    private var getShowCancellable: AnyCancellable?
    private var getEpisodesCancellable: AnyCancellable?
    
    /**
     * This show search only returns 10 results max, by design.
     * see: https://www.tvmaze.com/threads/4042/how-can-i-get-more-than-10-results-from-simple-search
     */
    func getShows(_ titleText: String, showConsumer: @escaping ([TVMazeShow])->()) {
        guard let titleEncodedText = titleText.stringByAddingPercentEncodingForRFC3986() else {
            return
        }
        guard let url = URL(string: "https://api.tvmaze.com/search/shows?q=\(titleEncodedText)") else {
            return
        }
        getShowsCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [TVMazeShowResult].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .sink(receiveValue: { results in
                print("\(results.count) results returned.")
                let shows:[TVMazeShow] = results.map {
                    let show = $0.show
                    let name = show.name ?? "No name"
                    print(name)
                    return show
                }
                showConsumer(shows)
            })
    }
    
    func getShow(_ showId: Int, showConsumer: @escaping (TVMazeShow?)->()) -> AnyCancellable? {
        guard let url = URL(string: "https://api.tvmaze.com/shows/\(showId)") else {
            return nil
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TVMazeShow?.self, decoder: JSONDecoder())
            .replaceError(with: nil)
            .eraseToAnyPublisher()
            .sink(receiveValue: { show in
                showConsumer(show)
            })
    }
    
    func getEpisodes(_ show: TVMazeShow, episodeConsumer: @escaping ([TVMazeEpisode])->()) {
        guard let url = URL(string: "https://api.tvmaze.com/shows/\(show.id)/episodes?specials=1") else {
            return
        }
        self.getEpisodesCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [TVMazeEpisode].self, decoder: JSONDecoder())
            .replaceError(with: [])
            .eraseToAnyPublisher()
            .sink(receiveValue: { episodes in
                print("\(episodes.count) episodes returned.")
                episodeConsumer(episodes)
            })
    }
}

extension String {
    func stringByAddingPercentEncodingForRFC3986() -> String? {
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return (self as NSString).addingPercentEncoding(withAllowedCharacters:allowed as CharacterSet)
    }
}
