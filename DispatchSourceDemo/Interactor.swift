//
//  Interactor.swift
//  DispatchSourceDemo
//
//  Created by Jeffrey Blagdon (work) on 2022-10-20.
//

import Foundation
import Combine
import Dispatch
import System

protocol Interactor: ObservableObject {
    var typedText: String { get set }
    var fileText: String { get }
    func updated(text: String)
}

enum Error: Swift.Error {
    case cantCreateFile
}

class ConcreteInteractor: Interactor {
    @Published var typedText: String = ""
    @Published var fileText: String = ""
    private let textPassthrough = PassthroughSubject<String, Never>()
    private var cancellables: Set<AnyCancellable> = []
    private let dispatchSource: DispatchSourceFileSystemObject
    private let queue = DispatchQueue(label: "co.polyergy.read")
    
    init() throws {
        let filename = ProcessInfo().globallyUniqueString
        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        let didCreate = FileManager.default.createFile(atPath: tempFileURL.path, contents: nil)
        assert(didCreate)
        
        let writeHandle = try! FileHandle(forWritingTo: tempFileURL)
        let readHandle = try! FileHandle(forReadingFrom: tempFileURL)
        
        textPassthrough
//            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
            .sink(receiveValue: { text in
                do {
//                    try text.write(to: tempFileURL, atomically: true, encoding: .utf8)
                    try writeHandle.truncate(atOffset: 0)
                    try writeHandle.write(contentsOf: text.data(using: .utf8) ?? Data())
                } catch {
                    print("Error writing to file: \(error)")
                }
            })
            .store(in: &cancellables)
        
        self.dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: readHandle.fileDescriptor, eventMask: .all, queue: DispatchQueue.main)
        self.dispatchSource.setEventHandler(handler: { [weak self] in
            do {
                try readHandle.seek(toOffset: 0)
                guard let data = try readHandle.readToEnd() else {
                    print("No data")
                    return
                }
                guard let text = String(data: data, encoding: .utf8) else {
                    print("Can't decode")
                    return
                }
                self?.fileText = text
            } catch {
                print("Error reading: \(error)")
            }
        })

        dispatchSource.setCancelHandler(handler: {
            do {
                try readHandle.close()
            } catch {
                print("Error closing handle: \(error)")
            }
        })
        dispatchSource.resume()
    }
    
    func updated(text: String) {
        typedText = text
        textPassthrough.send(text)
    }
    
    deinit {
        self.dispatchSource.cancel()
    }
}
