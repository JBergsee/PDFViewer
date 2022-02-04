import XCTest
@testable import PDFViewer

class PDFViewerTests: XCTestCase {
    
    var sut:PDFViewController!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        sut = PDFViewController()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil;
        try super.tearDownWithError()
    }
    
    
    func testPDFViewController()  throws {
        XCTAssert(sut != nil, "Could not create PDFViewController")
    }
    
}
