//
//  ViewController.swift
//  Face Recognition
//
//  Created by Charles Martin Reed on 12/7/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController {

    var image: UIImage!
    var scaledHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //image inside the view controlller, maintain aspect ratio
        image = UIImage(named: "people5")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit //maintain a 1:1 ratio when resizing image
        
        //height offset for safe area
        
        //ratio of image width * height. Look into the math on this one.
        scaledHeight = view.frame.width / image.size.width * image.size.height
        
        //set the frame
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: scaledHeight)
        
        view.addSubview(imageView)
        
        faceDetection()
    }
    
    func faceDetection() {
        //make the request
        let request = VNDetectFaceRectanglesRequest { (req, err) in
            if let err = err {
                print("Failed to detect faces", err)
                return
            }
            
            //we get a detect object, let's see what our results are
            req.results?.forEach({ (res) in
                //print(res)
                
                //code here needs to happen on a main thread
                DispatchQueue.main.async {
                    //cast from Any type
                    guard let faceObservation = res as? VNFaceObservation else { return }
                    
                    //measurements for our bounding box
                    let x = self.view.frame.width * faceObservation.boundingBox.origin.x
                    let height = self.scaledHeight * faceObservation.boundingBox.height
                    
                    //1 - because boundingBox starts at the lower left corner, - height to shift the box upward by the bounding box amount
                    let y = self.scaledHeight * (1 -  faceObservation.boundingBox.origin.y) - height
                    let width = self.view.frame.width * faceObservation.boundingBox.width
                    
                    
                    
                    //create the redView to visualize our bounding box
                    let redView = UIView()
                    redView.backgroundColor = .red
                    redView.alpha = 0.4
                    redView.frame = CGRect(x: x, y: y, width: width, height: height)
                    self.view.addSubview(redView)
                    
                    print(faceObservation.boundingBox) //box, of in this case, face, of the detected object. Origin point is the lower-left corner. CGRect
                }
            })
        }
        
        //pass the request to the image request handler
        //needs a CGimage
        
        //handling this request handler call inside of a background thread because it needs to happen asynchronously
        DispatchQueue.global(qos: .background).async {
            guard let image = self.image.cgImage else { fatalError() }
            
            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch let reqErr {
                print("Could not perform request", reqErr)
            }

        }
    }


}

