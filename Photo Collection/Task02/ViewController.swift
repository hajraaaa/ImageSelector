import UIKit
import Photos

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CustomCellDelegate, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images: [UIImage] = [] // Array to store selected images
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Register the custom cell class
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "CustomCell")
        
        // Set up the layout for the collection view
        let layout = UICollectionViewFlowLayout()
        
        // Spacing between items in the same row
        layout.minimumInteritemSpacing = 2
        
        // Spacing between rows
        layout.minimumLineSpacing = 10
        
        // Insets for the section
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        
        // Size of each item in the collection view
        layout.itemSize = CGSize(width: 100, height: 100)
        
        collectionView.collectionViewLayout = layout
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1 // Number of images plus one for the plus button
    }
    
    // Configures the cell for each item in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        if indexPath.item < images.count {
            // Display the selected image
            cell.imageView.image = images[indexPath.item]
            
            // Hide the plus button for image cells
            cell.plusButton.isHidden = true
        } else {
            // Display the plus button in the last cell
            cell.imageView.image = nil
            
            // Show the plus button
            cell.plusButton.isHidden = false
            cell.delegate = self
        }
        return cell
    }
    
    // MARK: - CustomCellDelegate
    
    // Called when the plus button is tapped, showing the menu
    func didTapPlusButton(in cell: CustomCell) {
        showMenu()
    }
    
    // MARK: - Menu Handling
    
    // Displays an action sheet with options to choose a photo
    func showMenu() {
        let actionSheet = UIAlertController(title: nil, message: "Choose Photo", preferredStyle: .actionSheet)
        
        // Option to select a photo from the gallery
        actionSheet.addAction(UIAlertAction(title: "Select from Gallery", style: .default, handler: { _ in
            self.selectImageFromGallery()
        }))
        
        // Option to take a new photo using the camera
        actionSheet.addAction(UIAlertAction(title: "Select from Camera", style: .default, handler: { _ in
            self.selectImageFromCamera()
        }))
        
        // Cancel option to dismiss the action sheet
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    // Handles the selection of an image from the gallery
    func selectImageFromGallery() {
        
        // Check the authorization status for accessing the photo library
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            openGallery() // If authorized, open the gallery
        } else if status == .notDetermined {
            // Request authorization if it has not been determined yet
            PHPhotoLibrary.requestAuthorization { status in
                DispatchQueue.main.async {
                    if status == .authorized {
                        // Open the gallery if authorization is granted
                        self.openGallery()
                    } else {
                        // Show an alert if access is denied
                        self.showAccessDeniedAlert()
                    }
                }
            }
        } else {
            // Show an alert if access is denied
            self.showAccessDeniedAlert()
        }
    }
    
    // Handles the selection of an image from the camera
    func selectImageFromCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = .camera // Set the source type to camera
            imagePicker.delegate = self
            // Present the image picker
            present(imagePicker, animated: true, completion: nil)
        } else {
            // Show an alert if the camera is not available
            showAlert(title: "Camera Not Available", message: "The camera is not available on this device.")
        }
    }
    
    // Opens the gallery to select an image
    func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary // Set the source type to photo library
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Shows an alert if access to the photo library is denied
    func showAccessDeniedAlert() {
        let alert = UIAlertController(title: "Access Denied", message: "Please grant access to your photo library in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // Shows a generic alert with a given title and message
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    // Called when the user selects an image from the gallery or camera
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            images.append(image) // Add the selected image to the array
            collectionView.reloadData() // Reload the collection view to display the new image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Called when the user cancels the image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) // Dismiss the image picker
    }
}
