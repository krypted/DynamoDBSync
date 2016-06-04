//
//  MMCommandManualViewController.swift
//  MacMan
//
//
//

import UIKit

class MMCommandManualViewController: UIViewController {
    @IBOutlet weak var manualTextView: UITextView!

    var tableRow:MMTableRow?

    override func viewWillAppear(animated: Bool) {
        self.manualTextView.scrollEnabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        self.manualTextView.scrollEnabled = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = tableRow?.Command
        self.manualTextView.text = tableRow?.Manual
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
}
