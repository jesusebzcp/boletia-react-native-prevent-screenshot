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
      print("Image property set with value: \(image)") // Imprime el valor de la propiedad image
      if let url = URL(string: image), let data = try? Data(contentsOf: url), let imageSource = UIImage(data: data) {
        self.backgroundColor = UIColor(patternImage: imageSource)
        print("Image successfully set as background from URL") // Imprime si la imagen se ha establecido correctamente desde URL
      } else if let imageSource = UIImage(named: image) {
        self.backgroundColor = UIColor(patternImage: imageSource)
        print("Image successfully set as background from name") // Imprime si la imagen se ha establecido correctamente desde nombre
      } else {
        print("Failed to load image with name or URL: \(image)") // Imprime si la imagen no se pudo cargar
      }
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
  
  private func setup() {
    
      // Configure the UITextField
      self.textField.isSecureTextEntry = true
      self.textField.textColor = .white.withAlphaComponent(0.1)
      self.textField.isUserInteractionEnabled = false
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
          hiddenView.translatesAutoresizingMaskIntoConstraints = false
          hiddenView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
          hiddenView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
          hiddenView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
          hiddenView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  
      }

   
  }

  

  // Override addSubview method to add subviews to the secure container
  public override func addSubview(_ view: UIView) {
      self.bodyView?.addSubview(view)
  }
  
 
  public override func layoutSubviews() {
      super.layoutSubviews()
      self.bodyView?.layoutSubviews()
  }
  

}



extension UITextField {
    var secureContainer: UIView? {
        guard let container = subviews.filter({ subview in
            type(of: subview).description().contains("CanvasView")
        }).first else {
            return nil
        }
        
        return container
    }
}

