//
//  TVShowListViewModel.swift
//  Flicks
//
//  Created by Brad B on 22/07/20.
//  Copyright © 2020 Brad B. All rights reserved.
//

import Foundation

class TVShowListViewModel: ObservableObject {
    
    @Published var shows = [Show]()
    
    private var fetchedShows = [TVShowList]()
    
    var currentPage = 1
    
    init() {
        fetchShows(filter: "popular")
        currentPage += 1
    }
    
    func checkTotalShows(filter: String) {
        if fetchedShows.count < 20 {
            currentPage = currentPage + 1
            fetchShows(filter: filter)
        }
    }
    
    func fetchShows(filter: String) {
        
        WebService().getPopularTVShows(page: currentPage, filter: filter) { show in
            
            if let show = show {
                self.fetchedShows.append(show)
                for show in show.shows {
                    self.shows.append(show)
                }
            }
        }
        if let totalPages = fetchedShows.first?.totalPages {
            if currentPage <= totalPages {
                currentPage += 1

            }
        }
    }
}