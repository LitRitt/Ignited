//
//  PhotoLibraryImportOption.swift
//  Delta
//
//  Created by Riley Testut on 5/2/17.
//  Copyright © 2017 Riley Testut. All rights reserved.
//

import UIKit
import MobileCoreServices

class PhotoLibraryImportOption: NSObject, ImportOption
{
    let title = NSLocalizedString("Photo Library", comment: "")
    let image: UIImage? = nil
    
    private let presentingViewController: UIViewController
    private var completionHandler: ((Set<URL>?) -> Void)?
    
    init(presentingViewController: UIViewController)
    {
        self.presentingViewController = presentingViewController
        
        super.init()
    }
    
    func `import`(withCompletionHandler completionHandler: @escaping (Set<URL>?) -> Void)
    {
        self.completionHandler = completionHandler
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .fullScreen
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.mediaTypes = [kUTTypeImage as String]
        self.presentingViewController.present(imagePickerController, animated: true, completion: nil)
    }
}

extension PhotoLibraryImportOption: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let url = info[.imageURL] as! URL
        var data: Data? = nil
        
        if url.pathExtension.lowercased() == "gif"
        {
            do
            {
                data = try Data(contentsOf: url)
            }
            catch
            {
                print(error.localizedDescription)
            }
        }
        else
        {
            guard let image = info[.originalImage] as? UIImage, let rotatedImage = image.rotatedToIntrinsicOrientation() else {
                self.completionHandler?([])
                return
            }
            data = rotatedImage.pngData()
        }
        
        do
        {
            guard let data = data else {
                self.completionHandler?([])
                return
            }
            
            let temporaryURL = FileManager.default.uniqueTemporaryURL()
            try data.write(to: temporaryURL, options: .atomic)
            
            self.completionHandler?([temporaryURL])
        }
        catch
        {
            self.completionHandler?([])
        }
    }
}
