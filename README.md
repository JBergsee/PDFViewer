# PDFViewer

A view controller to present PDFs.
Includes thumbnails, printing, and navigating through PDF bookmarks (if exists).
To be presented on a navigation stack, but could also be embedded in a navigation controller for modal presentation.

Usage:

    @IBAction func openPDFView() {
        let docURL = Bundle.main.url(forResource: "file-example_PDF_1MB", withExtension: "pdf")
        var pdfDocument:PDFDocument?
        if ((docURL) != nil) {
            pdfDocument = PDFDocument(url: docURL!)
        }
        let vc = PDFViewController()
        vc.pdfDocument = pdfDocument
        vc.pdfTitle = "Example PDF"
        self.navigationController?.pushViewController(vc, animated: true)
    }
