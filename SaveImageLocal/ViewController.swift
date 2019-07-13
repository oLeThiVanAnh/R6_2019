//
//  ViewController.swift
//  SaveImageLocal
//
//  Created by vananh on 7/12/19.
//  Copyright © 2019 vananh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var saveImage: UIImageView!
    @IBOutlet weak var loadImage: UIImageView!
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var loadButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        urlTextField.text = "https://kenh14cdn.com/thumb_w/660/2019/7/12/h3-15629096913361030769556.png"
    }


    @IBAction func onSaveTouch(_ sender: Any) {
        if let imageData = self.saveImage.image {
            DispatchQueue.global(qos: .background).async {
                self.store(image: imageData,
                           forKey: "test",
                           withStorageType: .userDefaults)
            }
        }
    }
    
    @IBAction func onLoadTouched(_ sender: Any) {
        DispatchQueue.global(qos: .background).async {
            
            if let tempImage = self.retrieveImage(forKey: "test", inStorageType: .userDefaults) {
                DispatchQueue.main.async {
                    self.loadImage.image = tempImage
                }
            }
        }
    }
    
    
    @IBAction func onRunTouched(_ sender: Any) {
        let imageUrlString = urlTextField.text!
        if let imageUrl:URL = URL(string: imageUrlString) {
        
            // Start background thread so that image loading does not make app unresponsive
            DispatchQueue.global(qos: .userInitiated).async {
                
                if let imageData:NSData = NSData(contentsOf: imageUrl) {
                
                    // When from background thread, UI needs to be updated on main_queue
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData as Data)
                        self.saveImage.image = image
                        self.saveImage.contentMode = UIView.ContentMode.scaleAspectFit
                    
                    }
                }
            }
        }
    }
    
    enum StorageType {
        case userDefaults
        case fileSystem
    }
    
    private func filePath(forKey key: String) -> URL? {
        let fileManager = FileManager.default
        guard let documentURL = fileManager.urls(for: .documentDirectory,
                                                 in: FileManager.SearchPathDomainMask.userDomainMask).first else { return nil }
        
        return documentURL.appendingPathComponent(key + ".png")
    }
    
    private func store(image: UIImage,
                       forKey key: String,
                       withStorageType storageType: StorageType) {
        if let pngRepresentation = image.pngData() {
            switch storageType {
            case .fileSystem:
                if let filePath = filePath(forKey: key) {
                    do  {
                        try pngRepresentation.write(to: filePath,
                                                    options: .atomic)
                    } catch let err {
                        print("Saving file resulted in error: ", err)
                    }
                }
            case .userDefaults:
                UserDefaults.standard.set(pngRepresentation,
                                          forKey: key)
            }
        }
    }
    
    private func retrieveImage(forKey key: String,
                               inStorageType storageType: StorageType) -> UIImage? {
        switch storageType {
        case .fileSystem:
            if let filePath = self.filePath(forKey: key),
                let fileData = FileManager.default.contents(atPath: filePath.path),
                let image = UIImage(data: fileData) {
                return image
            }
        case .userDefaults:
            if let imageData = UserDefaults.standard.object(forKey: key) as? Data,
                let image = UIImage(data: imageData) {
                return image
            }
        }
        
        return nil
    }
}

