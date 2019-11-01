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
    var courses: Courses?
    // Full list from API call
    var allCourses: [SearchCourseViewModel] = []
    // Results from user search, or all if no filter is applied
    var filteredCourses: [SearchCourseViewModel] = []
    
    // MARK: - Methods
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Show a warning when no courses can be found
        //- Do this as well in updateSearchResults()
        guard let courses = courses else { return }
        showSearchController()
        updateAllCourses(courses)

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
    
    /// Updates the courses fetched from the API.
    func updateAllCourses(_ courses: Courses) {
        allCourses = courses.results.map { SearchCourseViewModel($0) }
        showCourses(allCourses)
    }
    
    /// Updates the courses in the view.
    func showCourses(_ courses: [SearchCourseViewModel]) {
        filteredCourses = courses
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the course the user has selected
        if let destination = segue.destination as? CourseDetailsViewController,
            let row = tableView.indexPathForSelectedRow?.row {
            let course = CourseDetailsCourseViewModel(courses!.results[row])
            destination.course = course
        }
    }

}

// MARK: - Table view data source
extension SearchTableViewController {
    // MARK: - Properties
    // Matches in IB
    var cellID: String { "searchCourseCell" }
    
    // MARK: - Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCourses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? SearchTableViewCell else {
            fatalError("The cell must be of type SearchTableViewCell.")
        }

        cell.course = filteredCourses[indexPath.row]
        return cell
    }
}


// MARK: - Search functions
extension SearchTableViewController: UISearchResultsUpdating {
    // Triggers when search controller gains/loses first responder status and when contents are changed
    // Does NOT trigger when user presses enter
    func updateSearchResults(for searchController: UISearchController) {
        // Don't filter when user (de)selects controller
        guard !searchController.isBeingPresented,
            !searchController.isBeingDismissed else { return }
        
        let searchTerms = searchController.searchBar.text
        
        if let searchTerms = searchTerms,
            !searchTerms.isEmpty {
            filteredCourses = courses!.filterResults(by: searchTerms,
                                                    as: SearchCourseViewModel.self)
        } else {
            filteredCourses = allCourses
        }
        
        showCourses(filteredCourses)
    }
}
