//
//  ContentView.swift
//  DispatchSourceDemo
//
//  Created by Jeffrey Blagdon (work) on 2022-10-20.
//

import SwiftUI

struct ContentView<I: Interactor>: View {
    @ObservedObject var interactor: I
    var body: some View {
        HStack {
            TextEditor(text: Binding(get: { interactor.typedText }, set: { interactor.updated(text: $0) }))
            TextEditor(text: Binding(get: { interactor.fileText }, set: { _ in }))
        }
        .frame(idealWidth: 2000, idealHeight: 2000)
    }
}

private class DummyInteractor: Interactor {
    var typedText: String = "Hello"
    
    var fileText: String = "Hello"
    
    func updated(text: String) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(interactor: DummyInteractor())
    }
}
