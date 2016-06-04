//
//  MMCommandListViewController.swift
//  MacMan
//
//
//

import UIKit

class MMCommandListViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
 
    var tableRows: Array<MMTableRow>?
    var lock: NSLock?
    var lastEvaluatedKey: [NSObject : AnyObject]!
    var doneLoading = false
    
    var searchController: UISearchController!
    var searchString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchController()
        
        tableRows = []
        lock = NSLock()
        
        MMDynamoDBManger.describeTable().continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
            if (task.error != nil && task.error!.domain == AWSDynamoDBErrorDomain) && (task.error!.code == AWSDynamoDBErrorType.ResourceNotFound.rawValue) {
                    let alertController = UIAlertController(title: "DynamoDB table doesn't exist.", message: "Table name: \(MacManDynamoDBTableName)", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: { (action:UIAlertAction) -> Void in })
                    alertController.addAction(okAction)

                    self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                //load table contents
                self.refreshList(true)
            }
            
            return nil
        })
    }

    func setupSearchController() {
        self.searchController = UISearchController(searchResultsController:  nil)
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationType.None
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.searchString = searchController.searchBar.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.refreshList(true)
    }
       
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func refreshList(startFromBeginning: Bool)  {
        if (self.lock?.tryLock() != nil) {
            if startFromBeginning {
                self.lastEvaluatedKey = nil;
                self.doneLoading = false
            }
            
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.defaultDynamoDBObjectMapper()

            let queryExpression = AWSDynamoDBQueryExpression()
            queryExpression.exclusiveStartKey = self.lastEvaluatedKey
            queryExpression.limit = 20;
            queryExpression.scanIndexForward = true
            queryExpression.hashKeyValues = MacManVersion
            
            if (self.searchString != "") {
                queryExpression.rangeKeyConditionExpression = "begins_with(Command, :rangeval)"
                queryExpression.expressionAttributeValues = [":rangeval":self.searchString];
            }
            
            dynamoDBObjectMapper.query(MMTableRow.self, expression: queryExpression).continueWithExecutor(AWSExecutor.mainThreadExecutor(), withBlock: { (task:AWSTask!) -> AnyObject! in
                
                if self.lastEvaluatedKey == nil {
                    self.tableRows?.removeAll(keepCapacity: true)
                }
                
                if task.result != nil {
                    let paginatedOutput = task.result as! AWSDynamoDBPaginatedOutput
                    for item in paginatedOutput.items as! [MMTableRow] {
                        self.tableRows?.append(item)
                    }
                    
                    self.lastEvaluatedKey = paginatedOutput.lastEvaluatedKey
                    if paginatedOutput.lastEvaluatedKey == nil {
                        self.doneLoading = true
                    }
                }
                
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                self.tableView.reloadData()
                
                if ((task.error) != nil) {
                    print("Error: \(task.error)")
                }
                return nil
            })
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rowCount = self.tableRows?.count {
            return rowCount;
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if let myTableRows = self.tableRows {
            let item = myTableRows[indexPath.row]
            cell.textLabel?.text = item.Command!
            
            if indexPath.row == myTableRows.count - 1 && !self.doneLoading {
                self.refreshList(false)
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "MMSegueShowCommandManualViewController" {
            let manualViewController = segue.destinationViewController as! MMCommandManualViewController
            if sender != nil {
                if (sender!.isKindOfClass(UITableViewCell)) {
                    let cell = sender as! UITableViewCell
                    let indexPath = self.tableView.indexPathForCell(cell)
                    let tableRow = self.tableRows?[indexPath!.row]
                    manualViewController.tableRow = tableRow
                }
            }
        }
    }
}