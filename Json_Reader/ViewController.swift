//
//  ViewController.swift
//  Json_Reader
//
//  Created by John Clute on 7/29/19.
//  Copyright © 2019 icreateiphoneapps. All rights reserved.
//
//  Purpose of this apps is to read data in the form of a json file from www.filltext.com.
//          Then present the data in a table.
//

import UIKit
import Foundation



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tblData = [[String]]()  // table to hold the data from www.filltext.com
    @IBOutlet weak var theTable: UITableView!   // table displaying the data.  Will use this also to call reloadData method.
    
    @IBAction func loadTableWithData(_ sender: Any) {
        // We are just reloading the table, the data has already been loaded,
        // now we are just presenting to the user.
        theTable.reloadData()
    }
    
    func getData () {
        // getData:
        // This is the workhorse method of the program.
        //  We are creating the url Link to the website
        // then calling the rest service, then storing the data in theTable.
        
        let path : NSString = "http://www.filltext.com/?rows=100&fname={firstName}&lname={lastName}&city={city}&pretty=true"
        
        // URL was failing when making the call, it was ignorming the special characters in the string
        // to fix this needed to call addingPercentEncoding, this escaped the special characters and created the
        // corrent url string.
        let urlPath: NSString = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! as NSString
        guard let url = URL(string: (urlPath as NSString) as String) else {return}
        
        // getting data from website via task.
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                // creating Json string from data after making sure we got the data.
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                // create the json array still confirming we have valid data too.
                guard let jsonArray = jsonResponse as? [[String: Any]] else {
                    return
                }
                
                // creating table from read data.
                // This can be slow if we have records more then 10,000, however, for this app this will
                // work fine.
                var i = 0
                for tmpArr in jsonArray {
                    let fname: String = tmpArr["fname"] as! String
                    let lname: String = tmpArr["lname"] as! String
                    let city: String = tmpArr["city"] as! String
                    self.tblData.append( [fname, lname, city] )
                    i = i+1
                }
  
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        
        task.resume()
    }
    
    @IBAction func clearData(_ sender: Any) {
        // clear table, remove all data from table
        tblData.removeAll()
        theTable.reloadData()  // redisplay table, show it has nothing.
        // reload data for next use, this will get the data before then hit the reload button.
        // all the app has to do is build the table and display it to the user.
        getData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // instead of putting all the data on one line, creating sections, 100 in total
        return tblData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // returning how many rows are in each section, Firstname, Lastname, City, returning 3
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // putting data into cell
        // which later will be passed back and displayed in the table.
        let testCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell")
        let theValue = tblData[indexPath.section][indexPath.item]
        var label = "First Name: "
        if indexPath.item == 1 {
            label = "Last Name: "
        } else if indexPath.item == 2 {
            label = "City: "
        }
        testCell.detailTextLabel?.text = "\(label)"
        testCell.textLabel?.text = "\(theValue)"
        
        return testCell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // getting the data when we first start the app.
        // this speeds up the table display.
        getData()
        theTable.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }


}

