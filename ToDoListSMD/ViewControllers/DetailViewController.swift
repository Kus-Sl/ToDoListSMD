//
//  DetailTableViewController.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 28.07.2022.
//

import UIKit

final class DetailViewController: UIViewController {
    override var navigationItem: UINavigationItem {
        let item = UINavigationItem(title: "Дело")
        item.rightBarButtonItem = UIBarButtonItem(title: "Сохранить", style: .done, target: nil, action: nil)
        item.leftBarButtonItem = UIBarButtonItem(title: "Отменить", style: .plain, target: nil, action: nil)
        return item
    }

    private var viewModel = DetailViewModel(todoItem: TodoItem(id: "1", text: "Умная мысль", importance: .important, isDone: true, creationDate: Date(), changeDate: nil, deadLine: Date(timeIntervalSince1970: 1231314151)))

    private lazy var scrollView = UIScrollView()
    private lazy var textView = UITextView()
    private lazy var tableView = UITableView()
    private lazy var deleteButton = UIButton()

    private lazy var tableViewHeight: NSLayoutConstraint = tableView.heightAnchor.constraint(equalToConstant: 116)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = UIColor.colorAssets.colorBlue
        view.backgroundColor = UIColor.colorAssets.backPrimary
        setupScrollView()
        setupLayout()
    }

    @objc func showOrHideDatePicker() {
        if viewModel.showOrHideDatePicker() {
            tableView.insertRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            tableViewHeight.constant = tableView.contentSize.height
        } else {
            tableView.deleteRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
            tableViewHeight.constant = 116
        }

        UIView.animate(withDuration: 0.5) {
            self.scrollView.layoutIfNeeded()
        }
    }

    func setupScrollView() {
        setupTextView()
        setupTableView()
        setupDeleteButton()

        scrollView.addSubview(textView)
        scrollView.addSubview(tableView)
        scrollView.addSubview(deleteButton)
        view.addSubview(scrollView)
    }

    func setupTextView() {
        textView.backgroundColor = UIColor.colorAssets.backSecondary
        textView.textColor = UIColor.colorAssets.labelPrimary
        //        textView.textColor = UIColor.colorAssets.labelTertiary
        textView.layer.cornerRadius = 16
        textView.textContainerInset = UIEdgeInsets(top: 17, left: 16, bottom: 12, right: 16)
        textView.textContainer.lineFragmentPadding = 0
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.isScrollEnabled = false
        textView.text = viewModel.text
    }

    func setupTableView() {
        tableView.separatorColor = UIColor.colorAssets.supportSeparator
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.layer.cornerRadius = 16
        tableView.estimatedRowHeight = 145
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(CellType.deadLine.getClass(), forCellReuseIdentifier: CellType.deadLine.getClass().cellReuseIdentifier())
        tableView.register(CellType.importance.getClass(), forCellReuseIdentifier: CellType.importance.getClass().cellReuseIdentifier())
        tableView.register(CellType.calendar.getClass(), forCellReuseIdentifier: CellType.calendar.getClass().cellReuseIdentifier())
    }

    func setupDeleteButton() {
        deleteButton.backgroundColor = UIColor.colorAssets.backSecondary
        deleteButton.setTitleColor(.colorAssets.labelTertiary, for: .normal)
        deleteButton.setTitleColor(.colorAssets.colorRed, for: .highlighted)
        deleteButton.layer.cornerRadius = 16
        deleteButton.setTitle("Удалить", for: .normal)
        deleteButton.isHighlighted.toggle()

        deleteButton.addTarget(self, action: #selector(showOrHideDatePicker), for: .touchUpInside)
    }

    func setupLayout() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide

        frameGuide.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        frameGuide.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        frameGuide.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        frameGuide.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        contentGuide.widthAnchor.constraint(equalTo: frameGuide.widthAnchor).isActive = true

        textView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor, constant: 16).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor, constant: -16).isActive = true
        tableView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor, constant: 16).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor, constant: -16).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor, constant: 16).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor, constant: -16).isActive = true

        textView.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 16).isActive = true
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true
        textView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -16).isActive = true
        tableViewHeight.isActive = true
        tableView.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: -16).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
        deleteButton.bottomAnchor.constraint(lessThanOrEqualTo: contentGuide.bottomAnchor).isActive = true
    }
}

// MARK: Table view data source
extension DetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = viewModel.getCellID(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! BaseCell
        cell.viewModel = viewModel
        return cell
    }
}

// MARK: Table view delegate
extension DetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        viewModel.getHeightForRows(indexPath)
    }
}





// MARK: Custom controls delegate
//extension DetailViewController: CustomControlsDelegate {
//    func showCalendar() {
//        cellTypes.append(.calendar)
//        let indexPath = IndexPath(row: cellTypes.count - 1, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//
//        UIView.animate(withDuration: 0.5) {
//            self.tableView.setNeedsDisplay()
//            self.tableViewHeight.constant = self.tableView.contentSize.height
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    func closeCalendar() {
//        cellTypes.removeLast()
//        let indexPath = IndexPath(row: cellTypes.count, section: 0)
//        tableView.deleteRows(at: [indexPath], with: .automatic)
//
//        UIView.animate(withDuration: 0.5) {
//            self.tableViewHeight.constant = 116
//            self.view.layoutIfNeeded()
//        }
//    }
//}






// Keyboards methods
//extension DetailViewController {
//    private func registerForKeyBoardNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHIde), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    @objc func kbWillShow(_ notification: NSNotification) {
////        guard let userInfo = notification.userInfo else { return }
////        guard let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
////        scrollView.contentOffset = CGPoint(x: 0, y: kbFrameSize.height)
//
//
//        if let kbFrameSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
//            let keyboardTopY = kbFrameSize.cgRectValue.origin.y
//            let convertedDeleteButtonFrame = view.convert(deleteButton.frame, from: deleteButton.superview)
//            let deleteButtonBottomY = convertedDeleteButtonFrame.origin.y + convertedDeleteButtonFrame.size.height
//
//            if deleteButtonBottomY > keyboardTopY {
//
//                let textBoxY = convertedDeleteButtonFrame.origin.y
//                  let newFrameY = (textBoxY - keyboardTopY / 2) * -1
//                  scrollView.frame.origin.y = newFrameY
//            }
//        }
//    }
//
//    @objc func kbWillHIde(_ notification: NSNotification) {
//        scrollView.frame.origin.y = 0
//    }
//}
