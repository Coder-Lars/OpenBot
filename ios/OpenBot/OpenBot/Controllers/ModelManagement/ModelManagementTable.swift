//
// Created by Nitish Yadav on 02/12/22.
//

import Foundation
import UIKit
import DropDown

class ModelManagementTable: UITableViewController {
    var blankScreen = UIView()
    var blankScreenWidth: NSLayoutConstraint!
    var blankScreenHeight: NSLayoutConstraint!
    var blankScreenLeadingAnchor: NSLayoutConstraint!
    var blankScreenTopAnchor: NSLayoutConstraint!
    var leadingAnchorOfDropdown: NSLayoutConstraint!
    var widthOfDropDownView: NSLayoutConstraint!
    var modelDropdown = DropDown()
    var modelClassLabel = UILabel()
    var popupWindow = UIView();
    var models: [String]!
    var selectedIndex: IndexPath!
    var popupWindowWidth: NSLayoutConstraint!
    var popupWindowHeight: NSLayoutConstraint!
    var popupWindowLeadingAnchor: NSLayoutConstraint!
    var popupWindowTopAnchor: NSLayoutConstraint!
    var dropDown = UIView()
    let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

    /// Called after the view controller has loaded.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame.origin.y = 250;
        setupHeader()
        setupNavigationBarItem()
        createAddModelButton()
        NotificationCenter.default.addObserver(self, selector: #selector(fileDownloaded), name: .fileDownloaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeBlankScreen), name: .removeBlankScreen, object: nil)
    }

    /// Initialization routine
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateModelItemList(type: "All")
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50));
        let modelLabel = createLabel(text: "Model");
        modelLabel.frame = CGRect.init(x: 20, y: 5, width: headerView.frame.width - 10, height: headerView.frame.height - 10)
        modelLabel.font = UIFont.boldSystemFont(ofSize: 25.0)
        headerView.addSubview(modelLabel)
        dropDown = createDropDown()
        headerView.addSubview(dropDown);
        return headerView
    }


    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }

    /// Called when the view controller's view's size is changed by its parent (i.e. for the root view controller when its window rotates or is resized).
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if currentOrientation == .portrait {
            dropDown.frame.origin.x = width / 2;
        } else {
            dropDown.frame.origin.x = height / 2;
        }
    }

    func setupHeader() {
        modelDropdown.hide()
        createModelSelectorDropDown()
    }

    /// setting up back button
    func setupNavigationBarItem() {
        if UIImage(named: "back") != nil {
            let backNavigationIcon = (UIImage(named: "back")?.withRenderingMode(.alwaysOriginal))!
            let newBackButton = UIBarButtonItem(image: backNavigationIcon, title: Strings.modelManagement, target: self, action: #selector(back(sender:)), titleColor: Colors.navigationColor ?? .white)
            navigationItem.leftBarButtonItem = newBackButton
        }
    }

    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateModelItemList(type: "All")
    }


    /// creating labels.
    func createLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text;
        label.textColor = Colors.border;
        return label;

    }

    /// creating dropdowns.
    func createDropDown() -> UIView {
        let ddView = UIView();
        ddView.frame = CGRect(x: Int(width) / 2, y: 0, width: Int(width) / 2, height: 50);
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showModelDropdown(_:)))
        ddView.addGestureRecognizer(tapGesture)
        modelClassLabel = createLabel(text: "All");
        modelClassLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 40);
        ddView.addSubview(modelClassLabel)
        let downwardImage = UIImageView()
        downwardImage.frame.size = CGSize(width: 5, height: 5)
        downwardImage.image = Images.downArrow
        ddView.addSubview(downwardImage)
        downwardImage.tintColor = Colors.border
        downwardImage.translatesAutoresizingMaskIntoConstraints = false
        downwardImage.trailingAnchor.constraint(equalTo: ddView.trailingAnchor, constant: -30).isActive = true
        downwardImage.topAnchor.constraint(equalTo: ddView.topAnchor, constant: 11.5).isActive = true
        return ddView
    }

    /// creating select model dropdown.
    func createModelSelectorDropDown() {
        modelDropdown.backgroundColor = Colors.freeRoamButtonsColor;
        modelDropdown.textColor =  traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black;
        let dropDownView = UIView(frame: CGRect(x: width / 2 + 20, y: 100, width: width / 2 - 80, height: 200));
        view.addSubview(dropDownView);
        modelDropdown.dataSource = ["All", "AutoPilot", "Detector", "Navigation"];
        modelDropdown.anchorView = dropDownView
        modelDropdown.width = 100;
        modelDropdown.selectionAction = { [unowned self] (index: Int, item: String) in
            modelClassLabel.text = item
            updateModelItemList(type: item)
        }
    }

    /// function called when model list type item is updated.
    func updateModelItemList(type: String) {
        switch type {
        case "All":
            models = Common.loadAllModelsName()
            modelClassLabel.text = "ALL"
        case "AutoPilot":
            models = Common.returnAllModelItemsName(mode: "AUTOPILOT")
            modelClassLabel.text = "AutoPilot"
        case "Detector":
            models = Common.returnAllModelItemsName(mode: "DETECTOR")
            modelClassLabel.text = "Detector"
        case "Navigation":
            models = []
            modelClassLabel.text = "Navigation"
        default:
            models = Common.loadAllModelsName()
            modelClassLabel.text = "ALL"
        }
        updateTable()
    }

    func updateTable() {
        tableView.reloadData()
    }


    /// function to create the black screen.
    func createBlankScreen() {
        view.addSubview(blankScreen);
        blankScreen.backgroundColor = Colors.freeRoamButtonsColor;
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        blankScreen.addGestureRecognizer(tap)
        blankScreen.translatesAutoresizingMaskIntoConstraints = false
        if currentOrientation == .portrait {
            blankScreenWidth = blankScreen.widthAnchor.constraint(equalToConstant: width);
            blankScreenHeight = blankScreen.heightAnchor.constraint(equalToConstant: height);
        } else {
            blankScreenWidth = blankScreen.widthAnchor.constraint(equalToConstant: height);
            blankScreenHeight = blankScreen.heightAnchor.constraint(equalToConstant: width);
        }
        NSLayoutConstraint.activate([blankScreenWidth, blankScreenHeight]);
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        models.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        super.tableView(tableView, heightForRowAt: indexPath)
        return 60
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! modelManagementCell
        cell.textLabel?.text = models[indexPath.item]
        if Common.isModelItemAvailableInBundle(modelName: models[indexPath.item]) {
            cell.downloadIconView.isHidden = true;
            return cell;
        }
        if Common.returnModelItem(modelName: models[indexPath.item]).pathType == "ASSET" {
            cell.downloadIconView.isHidden = true;
            return cell;
        }
        return createImageOnCell(cell: cell, index: indexPath.row);
    }

    /// function to create the add button.
    func createAddModelButton() {
        let addModel = UIButton();
        view.addSubview(addModel);
        addModel.backgroundColor = .blue;
        addModel.setImage(Images.plus, for: .normal)
        addModel.translatesAutoresizingMaskIntoConstraints = false;
        addModel.layer.cornerRadius = 10;
        addModel.widthAnchor.constraint(equalToConstant: 40).isActive = true;
        addModel.heightAnchor.constraint(equalToConstant: 40).isActive = true;
        addModel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20).isActive = true;
        addModel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        addModel.addTarget(self, action: #selector(addModels(_:)), for: .touchUpInside);
    }

    /// function to add models
    @objc func addModels(_ sender: UIButton) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ScreenBottomSheet") as? UIViewController {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
            }
            navigationController?.present(vc, animated: true)
        }
    }

    func createImageOnCell(cell: modelManagementCell, index: Int) -> modelManagementCell {
        cell.downloadIconView.isHidden = false
        cell.downloadIcon.isUserInteractionEnabled = true;
        cell.downloadIcon.tag = index
        let tap = UITapGestureRecognizer(target: self, action: #selector(download(_:)))
        cell.downloadIcon.addGestureRecognizer(tap)
        switch Common.isModelItemAvailableInDocument(modelName: models[index]) {
        case true:
            cell.downloadIcon.image = UIImage(named: "trash")
            cell.downloadIcon.frame.size = CGSize(width: 10, height: 10)
            break;
        case false:
            cell.downloadIcon.image = UIImage(named: "download-cloud")
            cell.downloadIcon.frame.size = CGSize(width: 10, height: 10)
            break;
        }
        return cell
    }

    func addProgressIcon(index: Int) {

    }

    /// download function to download the model from URL
    @objc func download(_ sender: UITapGestureRecognizer) {
        let indexOfSelectedModel = sender.view?.tag ?? 0
        selectedIndex = IndexPath(row: indexOfSelectedModel, section: 0);
        switch Common.isModelItemAvailableInDocument(modelName: models[indexOfSelectedModel]) {
        case true:
            deleteModel(modelName: models[indexOfSelectedModel])
            break;
        case false:
            createOverlayAlert()
            downloadModel(modelName: models[indexOfSelectedModel])
            break;
        }
    }

    /// function to show alert(prompt) on the screen
    func createOverlayAlert() {
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        loadingIndicator.startAnimating();
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didDeselectRowAt: indexPath)

    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        popupWindow = popupWindowView(frame: .zero, models[indexPath.row], "", "")
        selectedIndex = indexPath
        createBlankScreen()
        createPopupWindow()
    }

    /// function to download the model from internet and save it in local storage.
    func downloadModel(modelName: String) {
        let model = Common.returnModelItem(modelName: modelName)
        if model.path != "" {
            let url = URL.init(string: model.path)!
            FileDownloader.loadFileAsync(url: url, completion: { s, error in
                print("File downloaded to : \(s!)")
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .fileDownloaded, object: nil);
                }
            }, fileName: model.name);
        }
        tableView.reloadRows(at: [selectedIndex], with: .bottom)
    }

    /// function to create the prompt(popup) window
    func createPopupWindow() {
        view.addSubview(popupWindow)
        popupWindow.translatesAutoresizingMaskIntoConstraints = false
        popupWindowLeadingAnchor = popupWindow.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        if currentOrientation == .portrait {
            popupWindowHeight = popupWindow.heightAnchor.constraint(equalToConstant: 400);
            popupWindowHeight.isActive = true;
            popupWindowWidth = popupWindow.widthAnchor.constraint(equalToConstant: width - 20)
            popupWindowLeadingAnchor = popupWindow.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10)
            popupWindowTopAnchor = popupWindow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
        } else {
            popupWindowHeight = popupWindow.heightAnchor.constraint(equalToConstant: width);
            popupWindowHeight.isActive = true;
            popupWindowWidth = popupWindow.widthAnchor.constraint(equalToConstant: width + 20);
            popupWindowLeadingAnchor = popupWindow.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 25)
            popupWindowTopAnchor = popupWindow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -50)
        }
        NSLayoutConstraint.activate([popupWindowWidth, popupWindowTopAnchor, popupWindowLeadingAnchor])
        popupWindow.backgroundColor = Colors.modelDetail;
    }

    /// function to delete the model from local storage.
    func deleteModel(modelName: String) {
        let filesPath = DataLogger.shared.getDocumentDirectoryInformation()
        for url in filesPath {
            if Common.returnModelItem(modelName: modelName).name == url.lastPathComponent {
                DataLogger.shared.deleteFiles(fileNameToDelete: url.lastPathComponent)
            }
        }
        tableView.reloadRows(at: [selectedIndex], with: .bottom)
    }

    @objc func updateConnect(_ notification: Notification) {
        tableView.reloadData()
    }

    @objc func dismissKeyboard(_ sender: UIButton) {
        view.endEditing(true);
    }

    @objc func back(sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }

    @objc func showModelDropdown(_ sender: UIButton) {
        modelDropdown.show()
    }

    @objc func fileDownloaded() {
        alert.dismiss(animated: true);
        tableView.reloadRows(at: [selectedIndex], with: .bottom)
    }

    /// function to remove the black screen and display screen with ALL items.
    @objc func removeBlankScreen(_ notification: Notification) {
        if notification.object == nil {
            blankScreen.removeFromSuperview();
            updateModelItemList(type: "All")
            return;
        }
        if selectedIndex == nil {
            updateModelItemList(type: "All")
            blankScreen.removeFromSuperview();
            return;
        }
        if notification.object != nil {
            models[selectedIndex.row] = (notification.object as! String)
            tableView.reloadRows(at: [selectedIndex], with: .bottom);
            blankScreen.removeFromSuperview();
        }
        updateModelItemList(type: "All")
    }

}

class modelManagementCell: UITableViewCell {
    @IBOutlet weak var downloadIcon: UIImageView!
    @IBOutlet weak var downloadIconView: UIView!
}
