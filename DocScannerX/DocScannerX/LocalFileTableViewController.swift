//
//  LocalFileTableViewController.swift
//  DCS SuperScanner
//
//  Created by dynamsoft on 2017/11/2.
//  Copyright © 2017年 com.dynamsoft. All rights reserved.
//

import UIKit

class LocalFileTableViewController: UITableViewController {

    // MARK: - Properties
    
    var image: UIImage?
    var quickLookVC: QuickLookViewController?
    var localDatas: [LocalData]?
    var emptyImage: UIImageView?
    var emptyHint: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Custom `tableView.separatorInset`.
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        navigationItem.title = "Saved Files"
        
        /// Initialize `emptyImage` and `emptyHint`.
        emptyImage = UIImageView(image: UIImage(named: "empty"))
        emptyImage!.center = CGPoint(x: fullScreenSize.width/2, y: 200)
        emptyHint = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 44))
        emptyHint?.center = CGPoint(x: fullScreenSize.width/2, y: 350)
        emptyHint?.textColor = .gray
        emptyHint?.textAlignment = .center
        emptyHint?.text = "You have not saved any files"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = localDatas?.count else {
            return 0
        }
        return count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CustomTableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        guard let _ = localDatas else {
            return cell
        }
        
        cell.textLabel?.text = localDatas?[indexPath.row].dataName
        cell.textLabel?.lineBreakMode = .byTruncatingTail
        cell.detailTextLabel?.text = localDatas?[indexPath.row].dataTimeStamp
        cell.accessoryType = .disclosureIndicator
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.image = getThumbnailImageFrom(FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("/"+localDatas![indexPath.row].dataName), type: localDatas![indexPath.row].dataType)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard  let _ = localDatas else {
            view.backgroundColor = UIColor(red: 240/255, green: 239/255, blue: 244/255, alpha: 1)
            let uiView = UIView(frame: tableView.frame)
            uiView.addSubview(emptyHint!)
            uiView.addSubview(emptyImage!)
            return uiView
        }
        if localDatas?.count != 0 {
            view.backgroundColor = .clear
            let uiView = UIView(frame: .zero)
            return uiView
        } else {
            view.backgroundColor = UIColor(red: 240/255, green: 239/255, blue: 244/255, alpha: 1)
            let uiView = UIView(frame: tableView.frame)
            uiView.addSubview(emptyHint!)
            uiView.addSubview(emptyImage!)
            return uiView
        }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let index = localDatas?[indexPath.row] else {
            return
        }
        quickLookVC = QuickLookViewController()
        quickLookVC?.navigationItem.title = "Preview"
        self.navigationController?.pushViewController(quickLookVC!, animated: false)
        
        quickLookVC?.quickLook(type: index.dataType, in: index.dataName)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete", handler: {
            (_: UITableViewRowAction, indexPath: IndexPath) in
            self.deleteFile(fileName: (self.localDatas?[indexPath.row].dataName)!)
            self.localDatas?.remove(at: indexPath.row)
            NSKeyedArchiver.archiveRootObject(self.localDatas!, toFile: LocalData.ArchiveURL.path)
            tableView.deleteRows(at: [indexPath], with: .fade)
            /// When delete cells until `localDatas?.count == 0`, reload tableview to show specified footerView.
            if self.localDatas?.count == 0 {
                self.reload()
            }
        })
        return [deleteAction]
    }
    
    /// Retrieve local files information and reload `tableView`.
    func reload() {
        localDatas = (NSKeyedUnarchiver.unarchiveObject(withFile: LocalData.ArchiveURL.path) as? [LocalData])?.reversed()
        tableView.reloadData()
    }
    
    /**
     Delete file saved in APP's sandbox according to file path.
     
     - Parameter fileName: File name
     */
    private func deleteFile(fileName: String) {
        let path = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("/"+fileName)
        try! FileManager().removeItem(at: path)
    }

    /**
     Generate a thumbnail image from local files. If file type is PNG/JPEG, generate its thumbnail image.
     If file type is PDF, generate its first page's thumbnail image.
     
     - Parameters:
        - path: File url
        - type: File type
     
     - Returns: Thumbnail image
     */
    private func getThumbnailImageFrom(_ path: URL, type: UInt) -> UIImage? {
        switch type {
        case FileType.PNG.rawValue, FileType.JPEG.rawValue:
            image = UIImage(contentsOfFile: path.path)
            var imageSize = CGSize(width: 60, height: 60)
            if image!.size.width > image!.size.height {
                imageSize.height = 60*image!.size.height/image!.size.width
            } else {
                imageSize.width = 60*image!.size.width/image!.size.height
            }
            UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
            let imageRect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            image?.draw(in: imageRect)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        case FileType.PDF.rawValue:
            let pdf = CGPDFDocument(path as CFURL)
            let firstPage = pdf?.page(at: 1)
            let pageRect = firstPage?.getBoxRect(.mediaBox)
            UIGraphicsBeginImageContext(pageRect!.size)
            let context = UIGraphicsGetCurrentContext()
            context?.saveGState()
            context?.translateBy(x: 0, y: pageRect!.size.height)
            context?.scaleBy(x: 1, y: -1)
            context?.concatenate((firstPage?.getDrawingTransform(.mediaBox, rect: pageRect!, rotate: 0, preserveAspectRatio: true))!)
            context?.drawPDFPage(firstPage!)
            context?.restoreGState()
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            var imageSize = CGSize(width: 60, height: 60)
            if image!.size.width > image!.size.height {
                imageSize.height = 60*image!.size.height/image!.size.width
            } else {
                imageSize.width = 60*image!.size.width/image!.size.height
            }
            UIGraphicsBeginImageContextWithOptions(imageSize, false, UIScreen.main.scale)
            let imageRect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
            image?.draw(in: imageRect)
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        default:
            return nil
        }
        return image
    }
    
}
