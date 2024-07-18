//
//  PremiumPatronsView.swift
//  Ignited
//
//  Created by Chris Rittenhouse on 7/18/24.
//  Copyright © 2024 LitRitt. All rights reserved.
//

import SwiftUI
import SafariServices

private extension NavigationLink where Label == EmptyView, Destination == EmptyView
{
    // Copied from https://stackoverflow.com/a/66891173
    static var empty: NavigationLink {
        self.init(destination: EmptyView(), label: { EmptyView() })
    }
}

extension PremiumPatronsView
{
    fileprivate class ViewModel: ObservableObject
    {
        @Published
        var patronsResult: Result<[Patron], Error>?
        
        @Published
        var patrons: [Patron]?
        
        @Published
        var error: Error?
        
        weak var hostingController: UIViewController?
        
        func fetchPatrons()
        {
            if let result = self.patronsResult, case .failure = result
            {
                self.patronsResult = nil
            }
            
            PatreonAPI.shared.fetchPatrons(.premium) { (result) in
                DispatchQueue.main.async {
                    self.patronsResult = result
                }
                
                do
                {
                    let patrons = try result.get()
                    let sortedPatrons = patrons.sorted { $0.name < $1.name  }
                    
                    DispatchQueue.main.async {
                        self.patrons = sortedPatrons
                    }
                }
                catch
                {
                    print("Failed to fetch patrons:", error)
                    
                    DispatchQueue.main.async {
                        self.error = error
                    }
                }
            }
        }
    }
    
    static func makeViewController() -> UIHostingController<some View>
    {
        let viewModel = ViewModel()
        let contributorsView = PremiumPatronsView(viewModel: viewModel)
        
        let hostingController = UIHostingController(rootView: contributorsView)
        hostingController.title = NSLocalizedString("Premium", comment: "")
        
        viewModel.hostingController = hostingController
                
        return hostingController
    }
}

struct PremiumPatronsView: View
{
    @StateObject
    private var viewModel: ViewModel
    
    @State
    private var showErrorAlert: Bool = false
    
    var body: some View {
        List {
            Section(content: {}, footer: {
                Text("These individuals have become patrons of the highest tier. Their support helps make the continued development of my apps and projects possible. ❤️‍🔥")
                    .font(.subheadline)
            })
            
            ForEach(viewModel.patrons ?? []) { patron in
                Section {
                    HStack {
                        Text("🔥")
                        Spacer()
                        
                        Text(patron.name).font(.system(size: 18)).bold()
                        
                        Spacer()
                        Text("🔥")
                    }
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
            viewModel.fetchPatrons()
        }
    }
    
    fileprivate init(patrons: [Patron]? = nil, viewModel: ViewModel = ViewModel())
    {
        if let patrons
        {
            // Don't overwrite passed-in viewModel.patrons if patrons is nil.
            viewModel.patrons = patrons
        }
        
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
}
