//
//  DetailView.swift
//  Flicks
//
//  Created by Brad B on 11/06/20.
//  Copyright © 2020 Brad B. All rights reserved.
//

import SwiftUI
import GoogleMobileAds

struct MovieDetailView: View {
    
    @ObservedObject private var detailVM = MovieDetailViewModel()
    @ObservedObject var watchListVM = WatchListViewModel()
    
    // Core data
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var movie: Movie
    
    @State private var showingAlert = false
    
    init(movie: Movie) {
        self.movie = movie
        
        // Stop Scrollview bounce
        UIScrollView.appearance().bounces = false
    }
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            // Movie poster
            MovieHeroImage(movie: movie, runTime: detailVM.fetchedMovie?.runTime ?? 0)
            
            VStack(alignment: .leading) {
                
                if detailVM.fetchedMovie?.genres?.count ?? 0 >= 1 {
                    
                    // Genre
                    Text("\(detailVM.fetchedMovie?.genres?.first?.name ?? "")")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(2)
                        .border(Color.gray)
                    
                }
                
                // Synopsis
                Text(movie.overview)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                
                // Cast members
                if detailVM.fetchedMovie?.credits != nil {
                    CastView(cast: (detailVM.fetchedMovie?.credits!.cast)!)
                        .buttonStyle(PlainButtonStyle())
                }
                
                if detailVM.recommendedMovies.isEmpty {
                    // Do nothing
                } else {
                    Text("Similar Movies")
                        .font(.title2)
                    
                    // Recommended movies
                    RecommendedMoviesView(movies: detailVM.recommendedMovies)
                }
                
                // TMDB attribution
                AttributionView()
                
            }.padding()
        }.onAppear(perform: {
            detailVM.getMovieDetails(id: movie.id)
            detailVM.getRecommendedMovies(movie: movie.id)
        })
        
        //        BannerAdView()
        
        .navigationBarTitle(movie.title ?? "")
        .navigationBarItems(trailing:
                                Button(action: {
                                    
                                    // Save to core data
                                    let movieToBeSaved = SavedMovie(context: self.managedObjectContext)
                                    movieToBeSaved.title = self.movie.title
                                    movieToBeSaved.id = Int32(self.movie.id)
                                    movieToBeSaved.backdropPath = self.movie.backdropPath
                                    movieToBeSaved.popularity = self.movie.popularity
                                    movieToBeSaved.releaseDate = self.movie.releaseDate
                                    movieToBeSaved.posterPath = self.movie.posterPath
                                    movieToBeSaved.overview = self.movie.overview
                                    movieToBeSaved.voteAverage = self.movie.voteAverage
                                    movieToBeSaved.voteCount = Int32(self.movie.voteCount)
                                    movieToBeSaved.runTime = Int32(self.movie.runTime ?? 0)
                                    
                                    self.showingAlert = true
                                    
                                    do {
                                        try self.managedObjectContext.save()
                                    } catch {
                                        // handle the Core Data error
                                    }
                                }) {
                                    Image(systemName: "bookmark")
                                        .foregroundColor(.white)
                                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: .trailing)
                                }.alert(isPresented: $showingAlert) {
                                    Alert(title: Text("Saved"), message: Text("Movie added to your watch list"), dismissButton: .default(Text("Ok")))
                                })
        
    }
}


//struct MovieDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        MovieDetailView(movie: Movie.example)
//    }
//}
