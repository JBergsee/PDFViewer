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
    
    private let showThumbnails:Bool!
    private let showPrint:Bool!
    private let showOutline:Bool!
    
    @IBOutlet private var pdfView: PDFView!
    @IBOutlet private var thumbnailView: PDFThumbnailView!
    @IBOutlet private var thumbnailViewLeadingEdgeConstraint: NSLayoutConstraint!
    
    private var outline: PDFOutline?
    private var outlineButton: UIBarButtonItem?
    
    public convenience init() {
        self.init(showThumbnails: true, showPrint: true, showOutline: true)
    }
    
    public init(showThumbnails:Bool = true, showPrint:Bool = true, showOutline:Bool = true) {
        self.showThumbnails = showThumbnails
        self.showPrint = showPrint
        self.showOutline = showOutline
        super.init(nibName: "PDFView", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        self.showThumbnails = false
        self.showPrint = false
        self.showOutline = false
        super.init(coder: coder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up the PDF Viewer
        
        if (showThumbnails) {
            //Thumbnail view
            thumbnailView.pdfView = pdfView
            thumbnailView.layoutMode = .vertical
            thumbnailView.thumbnailSize = CGSize(width: 100.0, height: 100.0) //This is the max size.
            thumbnailView.backgroundColor = UIColor.clear //secondarySystemBackground
            
            //Button to show thumbnails
            let thumbnailButton = UIBarButtonItem(image: UIImage.init(systemName: "sidebar.right"), style: .plain, target: self, action: #selector(toggleThumbnails))
            
            self.navigationItem.setRightBarButton(thumbnailButton, animated: false)

        }
        
        if (showPrint) {
            //Print button
            let printButton = UIBarButtonItem(image: UIImage.init(systemName: "printer"), style: .plain, target: self, action: #selector(airprint))
            var barButtonItems = self.navigationItem.rightBarButtonItems
            barButtonItems?.append(printButton)
            self.navigationItem.setRightBarButtonItems(barButtonItems, animated: false)
        }
        
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
        if (showOutline && self.outline != nil) {
            outlineButton = UIBarButtonItem(image: UIImage.init(systemName: "list.triangle"), style: .plain, target: self, action: #selector(showOutlineTable))
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
    
    @IBAction private func showOutlineTable() {
        
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
        dismiss(animated: true, completion: nil)
    }
}

extension PDFViewController: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
