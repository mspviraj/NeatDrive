//
//  LocalFilesViewController.swift
//  NeatDrive
//
//  Created by Nelson on 12/30/16.
//  Copyright © 2016 Nelson. All rights reserved.
//

import Foundation
import UIKit

class LocalFilesViewController : SlidableViewController, UITableViewDataSource, UITableViewDelegate, ACPViewControllerDelegate{
    
    @IBOutlet weak var tableView : UITableView?
    
    private var isEdit : Bool = false{
        
        didSet{
            
            self.tableView?.reloadData()
        }
    }
    
    var selectedData : [LocalFileMetadata] = Array<LocalFileMetadata>()
    
    var data : [[LocalFileMetadata]]? {
        
        didSet{
            
            self.tableView?.reloadData()
        }
    }
    
    var backbutton : UIBarButtonItem?
    
    var atRoot : Bool = true {
        
        didSet{
            
            if atRoot{
                
                self.removeLastLeftButton()
            }
            else {
                
                if self.backbutton == nil{
                    
                    self.backbutton = UIBarButtonItem(title: "<-", style: .plain, target: self, action: #selector(LocalFilesViewController.onBackToParent))
                }
                
                self.addLeftButton(button: self.backbutton!)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "All Files"
        
        LocalFileManager.shareInstance.onCurrentPathChanged = { isRoot in
        
            self.atRoot = isRoot
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        self.ReloadData()
 
        
        //we refresh back button
        if atRoot{
            
            self.atRoot = true
        }
        else {
            
            self.atRoot = false
        }
        
    }
    
    func processData(result:[LocalFileMetadata]){
        
        if result.count > 0{
            
            var dataSet : [[LocalFileMetadata]] = Array()
            var folderGroup : [LocalFileMetadata] = Array<LocalFileMetadata>()
            var fileGroup : [LocalFileMetadata] = Array<LocalFileMetadata>()
            
            for aData in result{
                
                if aData.IsFolder{
                    
                    folderGroup.append(aData)
                }
                else {
                    
                    fileGroup.append(aData)
                }
            }
            
            if folderGroup.count > 0{
                
                dataSet.append(folderGroup)
            }
            
            if fileGroup.count > 0{
                
                dataSet.append(fileGroup)
            }
            
            self.data = dataSet
        }
        else{
            
            self.data = nil
        }
    }
    
    func onBackToParent(){
        
        LocalFileManager.shareInstance.backToParent { result in
            
            self.processData(result: result)
        }
    }
    
    @IBAction func onPlusTap(){
        
        self.isEdit = true
        ACPViewController.showMenu(_delegate:self)
    }
    
    private func ReloadData(){
        
        LocalFileManager.shareInstance.contentsInPath(path: LocalFileManager.shareInstance.currentPathString, complete: { result in
            
            self.processData(result: result)
        })
    }
    
    private func presentErrorAlert(title:String?, msg:String?){
        
        let errorAlert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { action in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        errorAlert.addAction(okAction)
        
        self.present(errorAlert, animated: true, completion: nil)
    }
    
    private func isDataSelected(data : LocalFileMetadata) -> Bool{
        
        if isEdit{
            
            for d in selectedData{
                
                if data.isEqualTo(metaData: d){
                    
                    return true
                }
            }
            
            return false
        }
        
        return false
    }
    
    private func deselectData(data : LocalFileMetadata){
        
        if isEdit{
            
            var index : Int = -1
            
            for i in 0...(selectedData.count-1){
                
                let d = selectedData[i]
                
                if d.isEqualTo(metaData: data){
                    
                    index = i
                    
                    break
                }
            }
            
            if index >= 0{
                
                selectedData.remove(at: index)
                
                print("data \(data.FileName) deselect")
            }
        }
    }
    
    private func deselectAllData(){
    
        if isEdit{
            
            if self.selectedData.count > 0{
                
                self.selectedData.removeAll()
            }
        }
    
    }
    
    private func selectData(data : LocalFileMetadata){
        
        if !self.isDataSelected(data: data){
            
            selectedData.append(data)
            
            print("data \(data.FileName) select")
        }
        
    }
    
    private func filePathsFromSelectedData() -> [String]{
        
        var paths : [String] = Array<String>()
        
        if isEdit{
            
            for data in self.selectedData{
                
                paths.append(data.FilePath)
            }
        }
        
        return paths
    }
    
    //MARK:table data source
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.data != nil ? (self.data?.count)! : 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.data != nil ? self.data![section].count : 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let item = self.data?[section][0]
        
        return (item?.IsFolder)! ? "Folders" : "Files"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellId = "FileCell"
        
        let item : LocalFileMetadata = (self.data?[indexPath.section][indexPath.row])!
        
        var cell : FileCell? = tableView.dequeueReusableCell(withIdentifier: cellId) as? FileCell
        
        if cell == nil{
            
            cell = FileCell()
        }
        
        cell?.titleLabel?.text = item.FileName
        
        if item.IsFolder{
            cell?.subtitleLabel?.text = ""
        }
        else{
            
            cell?.subtitleLabel?.text = "File size : \(item.FileSizeString)"
        }
        
        cell?.isEdit = self.isEdit
        cell?.isSelect = self.isDataSelected(data: item)
        
        return cell!
    }
    
    //MARK:table delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item : LocalFileMetadata = self.data![indexPath.section][indexPath.row]
        
        if isEdit{
            
            if self.isDataSelected(data: item){
               
                //deselect data
                self.deselectData(data: item)
                
                let cell : FileCell = tableView.cellForRow(at: indexPath) as! FileCell
                
                cell.isSelect = false
            }
            else{
                
                //select data
                self.selectData(data: item)
                
                let cell : FileCell = tableView.cellForRow(at: indexPath) as! FileCell
                
                cell.isSelect = true
            }
        }
        else{
           
            if item.IsFolder{
                
                LocalFileManager.shareInstance.contentsInPath(path: item.FilePath, complete: { result in
                    
                    self.processData(result: result)
                })
            }
            else{
                
                //TODO:open file
            }
        }
        
    }
    
    //MARK:ACPViewControllerDataSource
    func menuItems() -> Array<ACPItem> {
        
        let arr : [ACPItem] = [
        
            ACPItem(acpItem: nil, iconImage: nil, label: "Add Folder", andAction: { item in
                
                print("add folder")
                
                let folderAlert = UIAlertController(title: "Create folder", message: "Give a name for new folder", preferredStyle: .alert)
                
                folderAlert.addTextField(configurationHandler: { (textField : UITextField) in
                    
                    textField.placeholder = "Name"
                    
                })
                
                let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { action in
                    
                    
                    let folderName = folderAlert.textFields?[0].text
                    
                    if folderName != ""{
                     
                        LocalFileManager.shareInstance.createfolderAtPath(path: LocalFileManager.shareInstance.currentPathString, folderName: folderName!, complete: { path, error in
                            
                            if error == nil{
                                
                                self.ReloadData()
                            }
                            else{
                                
                                switch error! {
                                    
                                case .folderExistError(_):
                                    
                                    self.presentErrorAlert(title: "Error", msg: "Folder \(folderName!) already exist")
                                    
                                    break
                                case .createFolderError(_):
                                    
                                    self.presentErrorAlert(title: "Error", msg: "Unable to create folder")
                                    
                                    break
                                
                                default:
                                    break
                                }
                            }
                        })
                    }
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    
                    self.dismiss(animated: true, completion: nil)
                })
                
                folderAlert.addAction(cancelAction)
                folderAlert.addAction(confirmAction)
                
                self.present(folderAlert, animated: true, completion: nil)
                
                
            }).setItemEnable(true).setEnableDisableAction({ item, enable in
                
                if enable {
                    
                    item?.labelItem.textColor = UIColor.darkGray
                }
                else{
                    
                    item?.labelItem.textColor = UIColor.lightGray
                }
            }),
            
            ACPItem(acpItem: nil, iconImage: nil, label: "Rename", andAction: { item in
                
                print("Re-name")
                
                let renameAlert = UIAlertController(title: "Rename", message: "Give it a new name", preferredStyle: .alert)
                
                renameAlert.addTextField(configurationHandler: { (textField : UITextField) in
                    
                    textField.placeholder = "Name"
                    
                    let data = self.selectedData.first
                    
                    textField.text = data?.FileNameWithoutExtension
                })
                
                let confirmAction = UIAlertAction(title: "Confirm", style: .default, handler: { action in
                    
                    
                    let newName = renameAlert.textFields?[0].text
                    
                    if newName != ""{
                        
                        let data = self.selectedData.first
                     
                        LocalFileManager.shareInstance.renameFile(filePath: (data?.FilePath)!, newName: newName!, complete: { filePath, error in
                            
                            if error == nil{
                                
                                self.deselectData(data: data!)
                                self.ReloadData()
                                
                            }
                            else{
                                
                                switch error! {
                                    
                                case .renameDuplicateError(_):
                                    
                                    self.presentErrorAlert(title: "Error", msg: "Name \(newName!) has been used")
                                    break
                                case .renameFileError(_):
                                    self.presentErrorAlert(title: "Error", msg: "Unable to rename")
                                    break
                                default:
                                    break
                                }
                            }
                        })
                    }
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    
                    self.dismiss(animated: true, completion: nil)
                })
                
                renameAlert.addAction(cancelAction)
                renameAlert.addAction(confirmAction)
                
                self.present(renameAlert, animated: true, completion: nil)
                
            }).setItemEnable(self.selectedData.count == 1 ? true : false).setEnableDisableAction({ item, enable in
                
                if enable {
                    
                    item?.labelItem.textColor = UIColor.darkGray
                }
                else{
                    
                    item?.labelItem.textColor = UIColor.lightGray
                }
            }),
            
            ACPItem(acpItem: nil, iconImage: nil, label: "Edit", andAction: { item in
                
                print("Edit")
                
                let menuAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                    
                    
                    let warningAlert = UIAlertController(title: "Delete files", message: "Are you sure you want to delete selected files?", preferredStyle: .alert)
                    
                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                        
                        LocalFileManager.shareInstance.deleteFiles(filePaths: self.filePathsFromSelectedData(), fileDeleted: { path in
                            
                            
                            }, complete: { error in
                                
                                if error == nil{
                                    
                                    self.deselectAllData()
                                    self.ReloadData()
                                }
                                else{
                                    
                                    switch error! {
                                    
                                    case .deleteFileError(_):
                                        
                                        self.presentErrorAlert(title: "Error", msg: "Unable to delete file")
                                        break
                                    default:
                                        break
                                    }
                                }
                        })
                    })
                    
                    let cancelAction = UIAlertAction(title: "No", style: .cancel, handler: { action in
                        
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    warningAlert.addAction(cancelAction)
                    warningAlert.addAction(deleteAction)
                    
                    self.present(warningAlert, animated: true, completion: nil)
                })
                
                let moveToAction = UIAlertAction(title: "Move To", style: .default, handler: { action in
                    
                    
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    
                    self.dismiss(animated: true, completion: nil)
                })
                
                menuAlert.addAction(cancelAction)
                menuAlert.addAction(moveToAction)
                menuAlert.addAction(deleteAction)
                
                self.present(menuAlert, animated: true, completion: nil)
                
            }).setItemEnable(self.selectedData.count >= 1 ? true : false).setEnableDisableAction({ item, enable in
                
                if enable {
                    
                    item?.labelItem.textColor = UIColor.darkGray
                }
                else{
                    
                    item?.labelItem.textColor = UIColor.lightGray
                }
            }),
            
            ACPItem(acpItem: nil, iconImage: nil, label: "Cancel Edit", andAction: { item in
                
                print("Cancel edit")
                
                self.isEdit = false
                
            }).setItemEnable(true).setEnableDisableAction({ item, enable in
                
                if enable {
                    
                    item?.labelItem.textColor = UIColor.darkGray
                }
                else{
                    
                    item?.labelItem.textColor = UIColor.lightGray
                }
            })
        ]
        
        return arr
    }
    
    func selectItemAtIndex(selectedIndex:Int){
        
    }
}
