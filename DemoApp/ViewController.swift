import UIKit

class ViewController: UITableViewController {
    var repositories: [Repository] = [] {
        didSet {
            tableView?.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let request = GitHub.Endpoint.SearchRepositories(query: "APIKit")
        
        GitHub.sendRequest(request) { response in
            switch response {
            case .Success(let box):
                self.repositories = box.unbox
                
            case .Failure(let box):
                let alertController = UIAlertController(title: "Error", message: box.unbox.localizedDescription, preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(action)
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        let repository = repositories[indexPath.row]
        
        cell.textLabel?.text = "\(repository.owner.login)/\(repository.name)"
        
        return cell
    }
}
