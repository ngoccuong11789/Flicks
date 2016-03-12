//
//  MovieViewController.swift
//  Flicks
//
//  Created by mac on 3/8/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MovieViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {

    @IBOutlet weak var errorNetworkView: UIView!
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    @IBOutlet weak var tableView: UITableView!
    let myRequest = NSURLRequest()
    var movies : [NSDictionary]?
    var filterMovie : [NSDictionary]?
    var endPoint: String!
    var titleArrays: [String]!
    var filterTitle = [String]()
    var searchController = UISearchController(searchResultsController: nil)
    let resultController = UITableViewController()
    var hidden = Bool()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        loadDataFromNetwork()
        networkRequest()
        filterMovie = movies
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        //Search Controller
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        self.tableView.tableHeaderView = self.searchController.searchBar
        
    }

    
    func networkRequest() {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            //self.errorNetworkView.hidden = true
                            print("response: \(responseDictionary)")
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
        })
        task.resume()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != ""{
            if let movies = filterMovie {
                return movies.count
            }else {
                return 0
            }
        }
        else {
            
            if let movies = movies {
                return movies.count
            }else {
                return 0
            }
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        var movie: NSDictionary
        if searchController.active && searchController.searchBar.text != "" {
            movie = filterMovie![indexPath.row]
        }else {
            movie = movies![indexPath.row]
        }
        
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        cell.lblTitle.text = title
        cell.lblOverview.text = overview
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let poster_path = movie["poster_path"] as? String {
        
           let imageURL = NSURL(string: baseUrl + poster_path)
           cell.posterView.setImageWithURL(imageURL!)
        }

        
        return cell
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UITableViewCell
        
        
        if searchController.active && searchController.searchBar.text != "" {
            let indexPath = tableView.indexPathForCell(cell)
            let movie = filterMovie![indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            
            detailViewController.movie = movie
            
        }else {
            let indexPath = tableView.indexPathForCell(cell)
            let movie = movies![indexPath!.row]
            
            let detailViewController = segue.destinationViewController as! DetailViewController
            
            detailViewController.movie = movie
        }
        
        
        
        
        
        
    }
    func refreshControlAction(refreshControl: UIRefreshControl) {
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        

        
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                
                self.tableView.reloadData()

                refreshControl.endRefreshing()	
        });
        task.resume()
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height

            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true

                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                loadMoreData()		
            }
        }
    }
    func loadMoreData() {
        
        // ... Create the NSURLRequest (myRequest) ...
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (data, response, error) in
                
                // Update flag
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
                // ... Use the new data to update the data source ...
                
                // Reload the tableView now that there is new data
                self.tableView.reloadData()
        });
        task.resume()
    }
        func loadDataFromNetwork() {
        
        // ... Create the NSURLRequest (myRequest) ...
            let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
            let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endPoint)?api_key=\(apiKey)")
            let request = NSURLRequest(
                URL: url!,
                cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
                timeoutInterval: 10)
            
        // Configure session so that completion handler is executed on main UI thread
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        // Display HUD right before the request is made
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(myRequest,
            completionHandler: { (data, response, error) in
                
                // Hide HUD once the network request comes back (must be done on main UI thread)
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                
                // ... Remainder of response handling code ...
                
        });
        task.resume()
    }
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filterMovie = movies?.filter{ movie in
            
            let title = movie["title"] as? String
            
            return (title!.lowercaseString.containsString(searchText.lowercaseString))
        }
        tableView.reloadData()
    }
//    func updateSearchResultForSearchController(searchController: UISearchController){
//        filterContentForSearchText(searchController.searchBar.text!)
//    }
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

