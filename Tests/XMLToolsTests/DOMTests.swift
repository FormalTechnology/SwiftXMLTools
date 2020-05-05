//
//  DOMTests.swift
//  XMLToolsTests
//
//  Created on 24.06.18
//
// swiftlint:disable nesting

import XCTest
@testable import XMLTools

class DOMTests: XCTestCase {

    func testManualCreationAndEval() {
        let doc = XMLTools.Document()
        let root = doc.appendElement("root")
        root.appendAttribute("aaa", withValue: "bbb")
        root.appendAttribute("name1", withNamespace: "urn:test", andValue: "ccc")

        XCTAssertEqual("root", doc.documentElement?.name().localName)
        XCTAssertEqual("bbb", doc.documentElement?.attributes[QName("aaa")]?.value)
        XCTAssertEqual("ccc", doc.documentElement?.attributes[QName("name1", uri: "urn:test")]?.value)
    }

    func testTraversal() {
        class Handler: DefaultDocumentHandler {

            var names = [QName]()

            override func startElement(_ element: Element, from document: Document) {
                names.append(element.name())
            }

        }

        let parser = XMLTools.Parser()

        let xml: XMLTools.Infoset
        do {
            xml = try parser.parse(contentsOf: "https://ec.europa.eu/information_society/policy/esignature/trusted-list/tl-mp.xml")
        } catch {
            print(error)
            XCTFail("\(error)")
            return
        }
        let handler = Handler()
        do {
            try xml.document().traverse(handler)
        } catch {
            XCTFail("\(error)")
        }
        XCTAssertTrue(handler.names.contains(QName("Name", uri: "http://uri.etsi.org/02231/v2#")))
    }

    func testChildNodes() throws {
        let doc = XMLTools.Document()
        let root = doc.appendElement("root")

        let book1 = root.appendElement("book")
        book1.appendAttribute("name", withValue: "The Hobbit")
        XCTAssertTrue(book1.parentNode === root)
        XCTAssertTrue(book1 === root.childNodes[0])

        let book2 = root.appendElement("book")
        book2.appendAttribute("name", withValue: "Lord of the Rings")
        XCTAssertTrue(book2.parentNode === root)
        XCTAssertTrue(book2 === root.childNodes[1])

        XCTAssertEqual(root.childNodes.count, 2)

        root.remove(at: 1)
        XCTAssertEqual(root.childNodes.count, 1)
        XCTAssertNil(book2.parentNode)

        try root.insert(book2, at: 0)
        XCTAssertEqual(root.childNodes.count, 2)
        XCTAssertTrue(book2.parentNode === root)

        book1.removeFromParent()
        XCTAssertEqual(root.childNodes.count, 1)
        XCTAssertNil(book1.parentNode)

        try root.append(book1)
        XCTAssertEqual(root.childNodes.count, 2)
        XCTAssertTrue(book1.parentNode === root)

        root.removeAll()
        XCTAssertTrue(root.childNodes.isEmpty)
        XCTAssertNil(book1.parentNode)
        XCTAssertNil(book2.parentNode)
    }

}
