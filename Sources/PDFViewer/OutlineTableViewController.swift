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
    
    //Delegate that can go to the selected chapter
    weak var delegate: OutlineDelegate?
    
    //The outline root, set before presentation
    var outlineRoot: PDFOutline?
    
    //Data model for table view
    private var data = [PDFOutline]()
    
    func prepareData() {
        for index in 0...(outlineRoot?.numberOfChildren)!-1 {
            let pdfOutline = outlineRoot?.child(at: index)
            pdfOutline?.isOpen = false
            data.append(pdfOutline!)
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareData()
    }
    
    
    //Connect action button to close this view
    public func closeOutlineView() {
        dismiss(animated: true, completion: nil)
    }
    
    init(outline: PDFOutline, delegate: OutlineDelegate?) {
        self.outlineRoot = outline
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        self.tableView.register(UINib(nibName: "OutlineCell", bundle: .module), forCellReuseIdentifier: "OutlineCell")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension OutlineTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
        tableView.dequeueReusableCell(withIdentifier: "OutlineCell", for: indexPath) as! OutlineCell
        
        let outline = data[indexPath.row];
        
        //Set tile and page number
        cell.titleLabel.text = outline.label
        cell.pageLabel.text = outline.destination?.page?.label
        
        //Fix button
        if outline.numberOfChildren > 0 {
            cell.openButton.setImage(outline.isOpen ? UIImage(systemName: "chevron.down") : UIImage(systemName: "chevron.right"), for: .normal)
            cell.openButton.isEnabled = true
        } else {
            cell.openButton.setImage(nil, for: .normal)
            cell.openButton.isEnabled = false
        }
        
        //Set action on button click
        cell.openButtonClick = {[weak self] (sender)-> Void in
            if outline.numberOfChildren > 0 {
                if sender.isSelected {
                    outline.isOpen = true
                    self?.insertChildren(parent: outline)
                } else {
                    outline.isOpen = false
                    self?.removeChildren(parent: outline)
                }
                tableView.reloadData()
            }
        }
        return cell
    }
    
    //Go to page on selection
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let outline = data[indexPath.row]
        if let page = outline.destination?.page {
            delegate?.goTo(page: page)
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        let outline = data[indexPath.row];
        let depth = findDepth(outline: outline)
        return depth;
    }
    
    func findDepth(outline: PDFOutline) -> Int {
        var depth: Int = -1
        var tmp = outline
        while (tmp.parent != nil) {
            depth = depth + 1
            tmp = tmp.parent!
        }
        return depth
    }
    
    func insertChildren(parent: PDFOutline) {
        var tmpData: [PDFOutline] = []
        let baseIndex = self.data.firstIndex(of: parent)
        for index in 0..<parent.numberOfChildren {
            if let pdfOutline = parent.child(at: index) {
                pdfOutline.isOpen = false
                tmpData.append(pdfOutline)
            }
        }
        self.data.insert(contentsOf: tmpData, at:baseIndex! + 1)
    }
    
    func removeChildren(parent: PDFOutline) {
        if parent.numberOfChildren <= 0 {
            return
        }
        
        for index in 0..<parent.numberOfChildren {
            if let node = parent.child(at: index) {
                if node.numberOfChildren > 0 {
                    removeChildren(parent: node)
                    // remove self
                    if let i = data.firstIndex(of: node) {
                        data.remove(at: i)
                    }
                } else {
                    if self.data.contains(node) {
                        if let i = data.firstIndex(of: node) {
                            data.remove(at: i)
                        }
                    }
                }
            }
        }
    }
}
