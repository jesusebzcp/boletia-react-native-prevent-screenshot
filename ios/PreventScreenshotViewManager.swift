import Foundation
import UIKit
import React

//Manager

@objc(PreventScreenshotViewManager)
class PreventScreenshotViewManager: RCTViewManager {

  override func view() -> (PreventScreenshotView) {
    return PreventScreenshotView()
  }

  @objc override static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
}


//View

@objc(PreventScreenshotView)
public final class PreventScreenshotView : UIView {
  
  @objc var image: String = "" {
    didSet {
      loadImageAsync(from: image)
    }
  }

  private let textField = UITextField()
  private var bodyView: UIView?
  

  // Custom initialization
  init() {
      super.init(frame: .zero)
      self.setup()
  }
  
  // Required initializer
  required init?(coder: NSCoder) {
      super.init(coder: coder)
      self.setup()
  }
  
  private func loadImageAsync(from image: String) {
    DispatchQueue.global(qos: .background).async { [weak self] in
      var imageSource: UIImage? = nil

      if let url = URL(string: image), let data = try? Data(contentsOf: url) {
        imageSource = UIImage(data: data)
      } else {
        imageSource = UIImage(named: image)
      }

      DispatchQueue.main.async {
        if let validImage = imageSource {
          self?.backgroundColor = UIColor(patternImage: validImage)
          print("Image successfully set as background")
        } else {
          print("Failed to load image with name or URL: \(image)")
        }
      }
    }
  }
  
  private func setup() {
    self.isUserInteractionEnabled = true
    
      // Configure the UITextField
      self.textField.isSecureTextEntry = true
      self.textField.textColor = .white.withAlphaComponent(0.1)
      self.textField.isUserInteractionEnabled = true
      self.textField.translatesAutoresizingMaskIntoConstraints = false
      super.addSubview(self.textField)

      // Add constraints to the UITextField
      self.textField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
      self.textField.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
      self.textField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
      self.textField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  

      // Get the secure container view of the UITextField
      if let hiddenView = self.textField.secureContainer {
          self.bodyView = hiddenView
          super.addSubview(hiddenView)
          hiddenView.isUserInteractionEnabled = false
          hiddenView.translatesAutoresizingMaskIntoConstraints = false
          hiddenView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
          hiddenView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
          hiddenView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
          hiddenView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  
      }

   
  }

  
}



extension UITextField {
    var secureContainer: UIView? {
        guard let container = subviews.filter({ subview in
            type(of: subview).description().contains("CanvasView")
        }).first else {
            return nil
        }
      container.isUserInteractionEnabled = true
        return container
    }
}
