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
  
  private var resizeModeBg : UIView.ContentMode = .scaleAspectFill
  
  @objc var image: String = "" {
    didSet {
      loadImageAsync(from: image)
    }
  }
  
  @objc var resizeMode: String = "" {
    didSet {
      resizeModeBg = updateResizeMode(resizeMode)
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
    print(resizeModeBg)
    print(resizeMode)
    
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
          hiddenView.isUserInteractionEnabled = true
          hiddenView.translatesAutoresizingMaskIntoConstraints = false
          hiddenView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
          hiddenView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
          hiddenView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
          hiddenView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
  
      }

   
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
              guard let validImage = imageSource else {
                  print("Failed to load image with name or URL: \(image)")
                  return
              }

      
              let backgroundImageView = UIImageView(image: validImage)
              backgroundImageView.contentMode = .scaleAspectFill  // Ajusta la imagen para que se adapte a la vista sin distorsión
              backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
              backgroundImageView.clipsToBounds = true // Asegura que la imagen no se salga de los bordes

        
              self?.subviews.forEach { subview in
                  if subview is UIImageView {
                      subview.removeFromSuperview()
                  }
              }

              if let strongSelf = self {
                  strongSelf.insertSubview(backgroundImageView, at: 0)

                
                  NSLayoutConstraint.activate([
                      backgroundImageView.leadingAnchor.constraint(equalTo: strongSelf.leadingAnchor),
                      backgroundImageView.trailingAnchor.constraint(equalTo: strongSelf.trailingAnchor),
                      backgroundImageView.topAnchor.constraint(equalTo: strongSelf.topAnchor),
                      backgroundImageView.bottomAnchor.constraint(equalTo: strongSelf.bottomAnchor)
                  ])
              }

              print("Image successfully set as responsive background")
          }
      }
  }
  
  private func updateResizeMode(_ mode: String) -> UIView.ContentMode {
     switch mode {
     case "cover":
       return .scaleAspectFill
     case "contain":
       return .scaleAspectFit
     case "stretch":
       return .scaleToFill
     case "center":
       return .center
     default:
       return .scaleAspectFill
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
