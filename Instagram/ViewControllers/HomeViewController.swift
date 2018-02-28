//
//  HomeViewController.swift
//  Instagram
//
//  Created by Ruben A Gonzalez on 2/26/18.
//  Copyright © 2018 Ruben A Gonzalez. All rights reserved.
//

import UIKit
import Parse

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post] = []
    let formatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.estimatedRowHeight = self.tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        tableView.insertSubview(refreshControl, at: 0)
        
        acquirePictures()
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        
        let year =  components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        
        print(year!)
        print(month!)
        print(day!)
        print(hour!)
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        acquirePictures()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        let post = posts[indexPath.row]
        
        // Make the username bold and combine username and caption
        // Assign usernamePlusCaption to captionLabel
        let caption = NSMutableAttributedString(string: " \(post.caption)")
        let attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17)]
        let usernamePlusCaption = NSMutableAttributedString(string:post.author.username!, attributes:attrs)
        usernamePlusCaption.append(caption)
        cell.captionLabel.attributedText =  usernamePlusCaption
        
        // Get the current date and set the date of the post based on it
        let createdDate = post.createdAt
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        cell.dateLabel.text = formatter.string(from: createdDate!)
        
        let imageFile = post.media
        imageFile.getDataInBackground(block: { (data, error) in
            if error == nil {
                DispatchQueue.main.async {
                    // Async main thread
                    let image = UIImage(data: data!)
                    cell.photoImageView.image = image
                }
            } else {
                print(error!.localizedDescription)
            }
        })
        
        return cell
    }

    func acquirePictures() {
        // construct PFQuery
        let query = Post.query()
        query?.order(byDescending: "createdAt")
        query?.includeKey("author")
        query?.limit = 20
        
        // fetch data asynchronously
        query?.findObjectsInBackground { (posts: [PFObject]?, error: Error?) -> Void in
            if let posts = posts {
                // do something with the data fetched
                self.posts = posts as! [Post]
                self.tableView.reloadData()
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
    }
    
    @IBAction func logOut(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
    }

    @IBAction func sharePhoto(_ sender: Any) {
        performSegue(withIdentifier: "photoSegue", sender: nil)
    }
    
    @objc func refreshControlAction(_ refreshControl: UIRefreshControl) {
        acquirePictures()
        // Tell the refreshControl to stop spinning
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
