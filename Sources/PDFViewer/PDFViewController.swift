//
//  ViewController.swift
//  PDFViewer
//
//  Created by Johan Nyman on 2022-02-04.
//

import PDFKit
import UIKit

@objcMembers
public class PDFViewController: UIViewController {
    
    
    public var pdfDocument: PDFDocument?
    public var pdfTitle: String?
    
    @IBOutlet private var pdfView: PDFView!
    @IBOutlet private var thumbnailView: PDFThumbnailView!
    @IBOutlet private var thumbnailViewLeadingEdgeConstraint: NSLayoutConstraint!
    
    private var outline: PDFOutline?
    private var outlineButton: UIBarButtonItem?
    
    public init() {
        super.init(nibName: "PDFView", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up the PDF Viewer
        
        //Thumbnail view
        thumbnailView.pdfView = pdfView
        thumbnailView.layoutMode = .vertical
        thumbnailView.thumbnailSize = CGSize(width: 100.0, height: 100.0) //This is the max size.
        thumbnailView.backgroundColor = UIColor.clear //secondarySystemBackground
        
        //Button to show thumbnails
        let thumbnailButton = UIBarButtonItem(image: UIImage.init(systemName: "sidebar.right"), style: .plain, target: self, action: #selector(toggleThumbnails))
        
        //Print button
        let printButton = UIBarButtonItem(image: UIImage.init(systemName: "printer"), style: .plain, target: self, action: #selector(airprint))
        
        self.navigationItem.setRightBarButtonItems([thumbnailButton, printButton], animated: false)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Is the title set?
        if (self.title == nil && self.pdfTitle != nil) {
            self.title = self.pdfTitle;
        }
        
        //Tell user if data is missing
        if (self.pdfDocument == nil) {
            let message = "No \"\(pdfTitle ?? "document")\" supplied"
            let alert = UIAlertController(title: "Missing PDF",
                                          message: message,
                                          preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: nil)
            alert.addAction(defaultAction)
            
            self.present(alert, animated: true, completion: nil)
            
        } else {
            self.outline = self.pdfDocument!.outlineRoot
            self.pdfView.document = self.pdfDocument
        }
        
        //Outline button
        if (self.outline != nil) {
            outlineButton = UIBarButtonItem(image: UIImage.init(systemName: "list.triangle"), style: .plain, target: self, action: #selector(showOutline))
            var barButtonItems = self.navigationItem.rightBarButtonItems
            barButtonItems?.append(outlineButton!)
            self.navigationItem.setRightBarButtonItems(barButtonItems, animated: false)
        }
    }
    
    
    @IBAction private func toggleThumbnails() {
        
        let thumbnailViewWidth = self.thumbnailView.frame.size.width;
        let screenWidth = UIScreen.main.bounds.size.width;
        let multiplier = thumbnailViewWidth / (screenWidth - thumbnailViewWidth) + 1.0;
        let isShowing = self.thumbnailViewLeadingEdgeConstraint.constant < 0;
        let scaleFactor = self.pdfView.scaleFactor;
        UIView.animate(withDuration: 0.5) {
            self.thumbnailViewLeadingEdgeConstraint.constant = isShowing ? 0 : -thumbnailViewWidth
            self.pdfView.scaleFactor = isShowing ? scaleFactor * multiplier : scaleFactor / multiplier
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction private func airprint() {

        guard let data = self.pdfDocument?.dataRepresentation(), UIPrintInteractionController.canPrint(data) else {
            return
        }
        
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = self.title ?? "Unnamed PDF"
        printInfo.outputType = .general
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.showsNumberOfCopies = false
        printController.printingItem = data
        printController.present(animated: true, completionHandler: nil)
    }
    
    @IBAction private func showOutline() {
        
        let outlineViewController = OutlineTableViewController(outline: self.outline!, delegate: self)
        outlineViewController.preferredContentSize = CGSize(width: 300, height: 400)
        outlineViewController.modalPresentationStyle = UIModalPresentationStyle.popover
        
        let popoverPresentationController = outlineViewController.popoverPresentationController
        popoverPresentationController?.barButtonItem = outlineButton
        popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up
        popoverPresentationController?.delegate = self
        
        self.present(outlineViewController, animated: true, completion: nil)
    }
}

extension PDFViewController: OutlineDelegate {
    func goTo(page: PDFPage) {
        pdfView.go(to: page)
    }
}

extension PDFViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
