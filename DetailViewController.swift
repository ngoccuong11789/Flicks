//
//  DetailViewController.swift
//  Flicks
//
//  Created by mac on 3/10/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var posterImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    
    var movie: NSDictionary!
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: infoView.frame.origin.y + infoView.frame.size.height)
        
        let title = movie["title"] as! String
        titleLabel.text = title
        let overview = movie["overview"] as! String
        overviewLabel.text = overview
        let Date = movie["release_date"] as! String
        lblDate.text = Date
        
        overviewLabel.sizeToFit()
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        if let poster_path = movie["poster_path"] as? String {
            
            let imageURL = NSURL(string: baseUrl + poster_path)
            posterImageView.setImageWithURL(imageURL!)
        }

    }

    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return infoView
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
