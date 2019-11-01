//
//  SearchTableViewController.swift
//  AllTheTime
//
//  Created by Xcode on ’19/11/01.
//  Copyright © 2019 Distant Labs. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController {
    
    // MARK: - Properties
    var courses: [SearchCourseViewModel] = []
    
    // MARK: - Methods
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSearchController()
        fetchCourses()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    // MARK: View
    
    /// Show search bar and make sure it's always showing, even when scrolling
    func showSearchController() {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "강의 검색"
        if #available(iOS 9.1, *) { searchController.obscuresBackgroundDuringPresentation = false }
        // Prevent UI issues in some cases (i.e. search controller overlapping views)
        definesPresentationContext = true
        
        // Listen for user changes
        searchController.searchResultsUpdater = self
        
        
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
            // Disable search controller hiding, so it shows up on load without scrolling
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController.searchBar
        }
    }
    
    // MARK: Courses
    
    /// Fetch full course list
    func fetchCourses(like searchTerms: String? = nil) {
        
        // TODO: Show a loading spinner while waiting
        
        Courses.fetch(code: searchTerms) { result in
            switch result {
            case .success(let courses):
                self.updateCourses(courses)
            case .failure(let error):
                print("Could not fetch courses: \(error.localizedDescription)")
            }
        }
    }
    
    func updateCourses(_ courses: Courses) {
        // Clear previous results
        self.courses.removeAll()
        
        // Add courses to array
        for course in courses.results {
            let viewModel = SearchCourseViewModel(course)
            self.courses.append(viewModel)
        }
        // Order by course code and display
        self.courses.sort { $0.code < $1.code }
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Table view data source
extension SearchTableViewController {
    // MARK: - Properties
    // Matches in IB
    var cellID: String { "searchCourseCell" }
    
    // MARK: - Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SearchTableViewCell else {
            fatalError("The cell must be of type SearchTableViewCell.")
        }

        cell.course = courses[indexPath.row]
        return cell
    }
}

// TODO: Case-insensitive searching? This is more a server-side requirement
// TODO: Right-side search field spinner? (or over table)
// TODO: Local search?

// MARK: - Search functions
extension SearchTableViewController: UISearchResultsUpdating {
    // Triggers when search controller gains/loses first responder status and when contents are changed
    // Does NOT trigger when user presses enter
    func updateSearchResults(for searchController: UISearchController) {
        // Don't filter when user (de)selects controller
        guard !searchController.isBeingPresented,
            !searchController.isBeingDismissed else { return }
        
        let searchTerms = searchController.searchBar.text
        fetchCourses(like: searchTerms)
    }
}
