//
//  LocalFilesViewController.swift
//  NeatDrive
//
//  Created by Nelson on 12/30/16.
//  Copyright © 2016 Nelson. All rights reserved.
//

import Foundation
import UIKit
import DGElasticPullToRefresh

class LocalFilesViewController : SlidableViewController, UITableViewDataSource, UITableViewDelegate, MoveFileDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var tableView : UITableView?
    @IBOutlet weak var menu : ACPScrollMenu?
    @IBOutlet weak var menuBottomConstraint : NSLayoutConstraint?
    @IBOutlet weak var plusBtn : UIButton?
    
    let loadingView = DGElasticPullToRefreshLoadingViewCircle()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var isEdit : Bool = false{
        
        didSet{
            
            self.deselectAllData()
            self.ReloadData()
            
            self.plusBtn?.isHidden = self.isEdit
            
            self.backbutton?.isEnabled = !self.isEdit
            
            if self.isEdit == true{
                
                
                self.setupMenuItems()
                self.showEditMenu(anim: true)
            }
            else{
                
                self.hideEditMenu(anim: true)
            }
            
            self.updateMenu()
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
    
    func getImageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x:0, y:0, width:size.width, height:size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "All Files"
        
        //configuer search bar
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.placeholder = "What are you looking for?"
        self.searchController.dimsBackgroundDuringPresentation = true
        
        self.definesPresentationContext = true
        self.tableView?.tableHeaderView = self.searchController.searchBar
        
        LocalFileManager.shareInstance.onCurrentPathChanged = { isRoot in
        
            self.atRoot = isRoot
        }
        
        self.setupMenuItems()
        
        //pull down refresh
        self.loadingView.tintColor = UIColor.white
        
        self.tableView?.dg_addPullToRefreshWithActionHandler({ 
            
            self.ReloadData()
            }, loadingView: self.loadingView)
        
        self.tableView?.dg_setPullToRefreshFillColor(UIColor(netHex: 0xeb5a27))
        self.tableView?.dg_setPullToRefreshBackgroundColor((tableView?.backgroundColor)!)
        
        self.ReloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.plusBtn?.layer.shadowColor = UIColor(netHex: 0xd4d4d4).cgColor
        self.plusBtn?.layer.shadowRadius = 3
        self.plusBtn?.layer.shadowOpacity = 1
        self.plusBtn?.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.plusBtn?.layer.masksToBounds = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
 
        
        //we refresh back button
        if atRoot{
            
            self.atRoot = true
        }
        else {
            
            self.atRoot = false
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //
        //configure search bar UI
        //
        self.searchController.searchBar.backgroundColor = UIColor.clear
        
        var searchBarBackgroundSize: CGSize? = nil
        
        for view in (self.searchController.searchBar.subviews.last?.subviews)!{
            
            if view.isKind(of: NSClassFromString("UISearchBarBackground")!){
                
                searchBarBackgroundSize = view.bounds.size
                break
            }
        }
        
        if searchBarBackgroundSize != nil{
            
            let image = imageWithBottomShadow(size: searchBarBackgroundSize!, imageColor: (self.tableView?.backgroundColor)!, shadowColor: UIColor(netHex: 0xd4d4d4), shadowHeight: (searchBarBackgroundSize?.height)! * (1/9))
            
            self.searchController.searchBar.backgroundImage = image
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
        
        if isEdit{
            
            self.deselectAllData()
        }
        
        LocalFileManager.shareInstance.backToParent { result in
            
            self.processData(result: result)
        }
    }
    
    @IBAction func onPlusTap(){
        
        self.isEdit = true
    }
    
    private func showEditMenu(anim:Bool){
        
        if anim{
            
            self.menuBottomConstraint?.constant = 0
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
            })
        }
        else{
            
            self.menuBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func hideEditMenu(anim:Bool){
        
        if anim{
            
            self.menuBottomConstraint?.constant = -(self.menu?.bounds.height)!
            UIView.animate(withDuration: 0.2, animations: {
                
                self.view.layoutIfNeeded()
            })
        }
        else{
            
            self.menuBottomConstraint?.constant = -(self.menu?.bounds.height)!
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateMenu(){
        
        
        if selectedData.count == 1{
            
            let mItem : ACPItem = self.menu?.menuItems()[1] as! ACPItem
            mItem.setItemEnable(true)
        }
        else{
            
            let mItem : ACPItem = self.menu?.menuItems()[1] as! ACPItem
            mItem.setItemEnable(false)
        }
    }
    
    /**
     Pull data from LocalFileManager
    */
    private func ReloadData(){
        
        self.deselectAllData()
        
        
        if self.searchController.searchBar.text == nil || self.searchController.searchBar.text == ""{
            
            LocalFileManager.shareInstance.contentsInPath(path: LocalFileManager.shareInstance.currentPathString, complete: { result in
                
                self.processData(result: result)
                
                //cancel pull down refresh
                self.tableView?.dg_stopLoading()
            })
        }
        else{
            
            LocalFileManager.shareInstance.searchFile(path: LocalFileManager.shareInstance.currentPathString, keyword: self.searchController.searchBar.text!, deepSearch: true) { result in
                
                self.processData(result: result)
                
                //cancel pull down refresh
                self.tableView?.dg_stopLoading()
            }
        }
        
        
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
            
            self.updateMenu()
        }
    }
    
    private func deselectAllData(){
    
        if isEdit{
            
            self.selectedData.removeAll()
            
            self.updateMenu()
        }
    
    }
    
    private func selectData(data : LocalFileMetadata){
        
        if !self.isDataSelected(data: data){
            
            if SystemFolderManager.shareInstance.isSystemFolder(path: data.FilePath){
                
                return
            }
            
            selectedData.append(data)
            
            print("data \(data.FileName) select")
            
            self.updateMenu()
        }
        
    }
    
    private func selectAllData(){
        
        if isEdit{
            
            self.selectedData.removeAll()
            
            for arr in self.data!{
                
                for d in arr{
                    
                    if SystemFolderManager.shareInstance.isSystemFolder(path: d.FilePath){
                        
                        continue
                    }
                    
                    self.selectedData.append(d)
                    
                    print("data \(d.FileName) select")
                }
            }
            
            self.updateMenu()
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
    
    //MARK:UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.text = nil
        self.ReloadData()
    }
 
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.disablePanGesture()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        self.enablePanGesture()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.ReloadData()
        self.searchController.isActive = false
    }

    
    //MARK:UISearchResultUpdating
    func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.searchBar.text == nil || searchController.searchBar.text == ""{
        
            return
        }
        
        self.ReloadData()
        
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
        
        cell?.isEdit = self.isEdit
        cell?.isSelect = self.isDataSelected(data: item)
        
        if item.IsFolder{
            cell?.subtitleLabel?.text = ""
            
            //system folder not allow to be edit
            if SystemFolderManager.shareInstance.isSystemFolder(path: item.FilePath){
                
                cell?.isEdit = false
                cell?.isSelect = false
            }
        }
        else{
            
            cell?.subtitleLabel?.text = "File size : \(item.FileSizeString)"
        }
        
        
        
        return cell!
    }
    
    //MARK:table delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item : LocalFileMetadata = self.data![indexPath.section][indexPath.row]
        
        if isEdit{
            
            //system folder not allow to be edit
            if SystemFolderManager.shareInstance.isSystemFolder(path: item.FilePath){
                
                return
            }
            
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
    
    //MARK:MoveFileDelegate
    func onCancel() {
        
    }
    
    func onDestinationPathPicked(path: String) {
        
        var filePaths : [String] = Array<String>()
        
        for selected in self.selectedData{
            
            filePaths.append(selected.FilePath)
        }
        
        LocalFileManager.shareInstance.moveFiles(filePaths: filePaths, destinationPath: path, fileMoved: { oldPath, newPath in
            
            
            }, complete:{error in
        
                if error == nil{
                    
                    self.ReloadData()
                }
                else{
                    
                    switch error!{
                    case .moveFileError(_):
                        self.presentErrorAlert(title: "Error", msg: "Unable to move files")
                        break
                    default:
                        break
                    }
                }
        })
    }
    
    //MARK:Setup ACPScrollMenu items
    func setupMenuItems() {
        
        self.menu?.fixSizeEnable = true
        
        let arr : [ACPItem] = [
        
            //add folder item
            ACPItem(acpItem: nil, iconImage: UIImage(named: "EditMenu-AddFolder"), label: "Add Folder", andAction: { item in
                
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
            
            //rename item
            ACPItem(acpItem: nil, iconImage: UIImage(named: "EditMenu-RenameGray"), label: "Rename", andAction: { item in
                
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
                
            }).setIconHighlightedImage(UIImage(named: "EditMenu-Rename")).setItemEnable(self.selectedData.count == 1 ? true : false).setEnableDisableAction({ item, enable in
                
                if enable {
                    
                    item?.labelItem.textColor = UIColor.darkGray
                    item?.iconImage.isHighlighted = true
                }
                else{
                    
                    item?.labelItem.textColor = UIColor.lightGray
                    item?.iconImage.isHighlighted = false
                }
            }),
            
            //edit item
            ACPItem(acpItem: nil, iconImage: UIImage(named: "EditMenu-EditFile"), label: "Edit", andAction: { item in
                
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
                
                let selectAllAction = UIAlertAction(title: "Select All", style: .default, handler: { action in
                    
                    self.selectAllData()
                    self.tableView?.reloadData()
                })
                
                let deselectAllAction = UIAlertAction(title: "Deselect All", style: .default, handler: { action in
                    
                    self.deselectAllData()
                    self.tableView?.reloadData()
                })
                
                let moveToAction = UIAlertAction(title: "Move To", style: .default, handler: { action in
                    
                    var files : [String] = Array<String>()
                    
                    for selected in self.selectedData{
                        
                        files.append(selected.FilePath)
                    }
                    
                    MoveFileController.presentInViewController(inController: self, _delegate: self, movedfiles: files)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                    
                    self.dismiss(animated: true, completion: nil)
                })
                
                menuAlert.addAction(cancelAction)
                
                if self.selectedData.count > 0{
                    
                    menuAlert.addAction(deleteAction)
                }
                
                menuAlert.addAction(deselectAllAction)
                menuAlert.addAction(selectAllAction)
                
                
                if self.selectedData.count > 0{
                    
                    menuAlert.addAction(moveToAction)
                }
                
                
                self.present(menuAlert, animated: true, completion: nil)
                
            }).setItemEnable(true).setEnableDisableAction({ item, enable in
                
                if enable {
                    
                    item?.labelItem.textColor = UIColor.darkGray
                }
                else{
                    
                    item?.labelItem.textColor = UIColor.lightGray
                }
            }),
            
            //cancel edit item
            ACPItem(acpItem: nil, iconImage: UIImage(named: "EditMenu-CancelEdit"), label: "Cancel Edit", andAction: { item in
                
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
        
        self.menu?.setUp(arr)
    }
}
