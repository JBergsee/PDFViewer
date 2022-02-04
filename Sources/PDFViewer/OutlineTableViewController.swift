//
//  OutlineViewController.swift
//  PDFViewer
//
//  Created by Johan Nyman on 2022-02-04.
//

import UIKit
import PDFKit

protocol OutlineDelegate: AnyObject {
    func goTo(page: PDFPage)
}

class OutlineTableViewController: UITableViewController {
    
    let outline: PDFOutline
    weak var delegate: OutlineDelegate?
    
    init(outline: PDFOutline, delegate: OutlineDelegate?) {
        self.outline = outline
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return outline.numberOfChildren
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        if let label = cell.textLabel, let title = outline.child(at: indexPath.row)?.label, let page = outline.child(at: indexPath.row)?.destination?.page {
            label.text = "\(title): \(page)"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let page = outline.child(at: indexPath.row)?.destination?.page {
            delegate?.goTo(page: page)
        }
    }

}
