//
//  PatronsView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 4/17/23.
//  Copyright © 2023 Lit Development. All rights reserved.
//

import SwiftUI
import SafariServices

struct Patron: Identifiable, Decodable
{
    var name: String
    
    var id: String {
        // Use names as identifiers for now.
        return self.name
    }
}

extension PatronsView
{
    fileprivate class ViewModel: ObservableObject
    {
        @Published
        var patrons: [Patron]?
        
        @Published
        var error: Error?
        
        weak var hostingController: UIViewController?
        
        func loadPatrons()
        {
            guard self.patrons == nil else { return }
            
            do
            {
                let fileURL = Bundle.main.url(forResource: "Patrons", withExtension: "plist")!
                let data = try Data(contentsOf: fileURL)
                
                let patrons = try PropertyListDecoder().decode([Patron].self, from: data)
                self.patrons = patrons
            }
            catch
            {
                self.error = error
            }
        }
    }
    
    static func makeViewController() -> UIHostingController<some View>
    {
        let viewModel = ViewModel()
        let patronsView = PatronsView(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: patronsView)
        hostingController.title = NSLocalizedString("Patrons", comment: "")
        
        viewModel.hostingController = hostingController
                
        return hostingController
    }
}

struct PatronsView: View
{
    @StateObject
    private var viewModel: ViewModel
    
    @State
    private var showErrorAlert: Bool = false
    
    var body: some View {
        List {
            Section(content: {}, footer: {
                Text("These patrons have shown overwhelming support for Ignited. Their contributions help make the development of this app possible. You are all certified Lit ❤️‍🔥")
                    .font(.subheadline)
            })
            
            ForEach(viewModel.patrons ?? []) { patron in
                Section {
                    // First row = patron
                    PatronCell(name: Text(patron.name).bold())
                }
            }
        }
        .listStyle(.insetGrouped)
        .environmentObject(viewModel)
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Unable to Load Patrons"), message: Text(viewModel.error?.localizedDescription ?? ""), dismissButton: .default(Text("OK")) {
                guard let hostingController = viewModel.hostingController else { return }
                hostingController.navigationController?.popViewController(animated: true)
            })
        }
        .onReceive(viewModel.$error) { error in
            guard error != nil else { return }
            showErrorAlert = true
        }
        .onAppear {
            viewModel.loadPatrons()
        }
    }
    
    fileprivate init(patrons: [Patron]? = nil, viewModel: ViewModel = ViewModel())
    {
        if let patrons
        {
            // Don't overwrite passed-in viewModel.contributors if contributors is nil.
            viewModel.patrons = patrons
        }
        
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}

struct PatronCell: View
{
    var name: Text
    var body: some View {
        
        HStack {
            self.name
                .font(.system(size: 17)) // Match Settings screen
            
            Spacer()
            
            Text("🔥")
        }
        .accentColor(.primary)
        .buttonStyle(.plain)
    }
}
