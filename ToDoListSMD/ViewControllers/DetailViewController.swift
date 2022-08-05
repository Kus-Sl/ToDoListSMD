//
//  DetailTableViewController.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 28.07.2022.
//

import UIKit

final class DetailViewController: UIViewController {
    override var navigationItem: UINavigationItem {
        let item = UINavigationItem(title: Constants.navigationItemTitle)
        item.rightBarButtonItem = UIBarButtonItem(title: Constants.navigationBarSaveButtonTitle, style: .done, target: nil, action: nil)
        item.leftBarButtonItem = UIBarButtonItem(title: Constants.navigationBarCancelButtonTitle, style: .plain, target: nil, action: nil)
        return item
    }

    private var viewModel = DetailViewModel(todoItem: TodoItem(id: "1", text: "Умная мысль", importance: .important, isDone: true, creationDate: Date(), changeDate: nil, deadLine: Date(timeIntervalSince1970: 1231314151)))

    private lazy var scrollView = UIScrollView()
    private lazy var textView = UITextView()
    private lazy var tableView = UITableView()
    private lazy var deleteButton = UIButton()

    private var tableViewHeight: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.tintColor = UIColor.colorAssets.colorBlue
        view.backgroundColor = UIColor.colorAssets.backPrimary
        setupScrollView()
        setupLayout()
    }

    @objc private func showOrHideDatePicker() {
        if viewModel.showOrHideDatePicker() {
            tableView.insertRows(at: [CellType.calendar.getRowIndexPath()], with: .automatic)
            tableViewHeight.constant = tableView.contentSize.height
        } else {
            tableView.deleteRows(at: [CellType.calendar.getRowIndexPath()], with: .automatic)
            tableViewHeight.constant = Constants.minTableViewHeight
        }

        UIView.animate(withDuration: Constants.animationDuration) {
            self.scrollView.layoutIfNeeded()
        }
    }

    private func setupScrollView() {
        setupTextView()
        setupTableView()
        setupDeleteButton()

        scrollView.addSubview(textView)
        scrollView.addSubview(tableView)
        scrollView.addSubview(deleteButton)
        view.addSubview(scrollView)
    }

    private func setupTextView() {
        textView.backgroundColor = UIColor.colorAssets.backSecondary
        textView.textColor = UIColor.colorAssets.labelPrimary
        //        textView.textColor = UIColor.colorAssets.labelTertiary
        textView.layer.cornerRadius = Constants.radius
        textView.textContainerInset = UIEdgeInsets(
            top: Constants.textContainerTopInset,
            left: Constants.textContainerLeftInset,
            bottom: Constants.textContainerBottomInset,
            right: Constants.textContainerRightInset
        )
        textView.textContainer.lineFragmentPadding = Constants.textContainerLineFragmentPadding
        textView.font = UIFont.body
        textView.isScrollEnabled = false
        textView.text = viewModel.text
    }

    private func setupTableView() {
        tableView.separatorColor = UIColor.colorAssets.supportSeparator
        tableView.separatorInset = UIEdgeInsets(
            top: Constants.separatorTopInset,
            left: Constants.SeparatorLeftInset,
            bottom: Constants.SeparatorBottomInset,
            right: Constants.SeparatorRightInset
        )
        tableView.layer.cornerRadius = Constants.radius

        tableView.estimatedRowHeight = 145 // без этого работает только со второго раза

        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(CellType.deadLine.getClass(), forCellReuseIdentifier: CellType.deadLine.getClass().cellReuseIdentifier())
        tableView.register(CellType.importance.getClass(), forCellReuseIdentifier: CellType.importance.getClass().cellReuseIdentifier())
        tableView.register(CellType.calendar.getClass(), forCellReuseIdentifier: CellType.calendar.getClass().cellReuseIdentifier())
    }

    private func setupDeleteButton() {
        deleteButton.backgroundColor = UIColor.colorAssets.backSecondary
        deleteButton.setTitleColor(.colorAssets.labelTertiary, for: .normal)
        deleteButton.setTitleColor(.colorAssets.colorRed, for: .highlighted)
        deleteButton.layer.cornerRadius = Constants.radius
        deleteButton.setTitle(Constants.deleteButtonTitle, for: .normal)
        deleteButton.isHighlighted.toggle()

        deleteButton.addTarget(self, action: #selector(showOrHideDatePicker), for: .touchUpInside)
    }

    private func setupLayout() {
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

        textView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor, constant: Constants.leadingInset).isActive = true
        textView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor, constant: Constants.trailingInset).isActive = true
        tableView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor, constant: Constants.leadingInset).isActive = true
        tableView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor, constant: Constants.trailingInset).isActive = true
        deleteButton.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor, constant: Constants.leadingInset).isActive = true
        deleteButton.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor, constant: Constants.trailingInset).isActive = true

        textView.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: Constants.leadingInset).isActive = true
        textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textViewHeight).isActive = true
        textView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: Constants.trailingInset).isActive = true
        tableViewHeight = tableView.heightAnchor.constraint(equalToConstant: Constants.minTableViewHeight)
        tableViewHeight.isActive = true
        tableView.bottomAnchor.constraint(equalTo: deleteButton.topAnchor, constant: Constants.trailingInset).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButtonHeight).isActive = true
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

// MARK: Constants
extension DetailViewController {
    private enum Constants {
        static let leadingInset: CGFloat = 16
        static let trailingInset: CGFloat = -16
        static let minTableViewHeight: CGFloat = 116
        static let textViewHeight: CGFloat = 120
        static let textContainerBottomInset: CGFloat = 12
        static let textContainerTopInset: CGFloat = 17
        static let textContainerLeftInset: CGFloat = 16
        static let textContainerRightInset: CGFloat = 16
        static let textContainerLineFragmentPadding: CGFloat = 0
        static let separatorTopInset: CGFloat = 0
        static let SeparatorBottomInset: CGFloat = 0
        static let SeparatorLeftInset: CGFloat = 16
        static let SeparatorRightInset: CGFloat = 16
        static let deleteButtonHeight: CGFloat = 56
        static let radius: CGFloat = 16
        static let animationDuration: CGFloat = 0.5
        static let navigationItemTitle = "Дело"
        static let navigationBarSaveButtonTitle = "Сохранить"
        static let navigationBarCancelButtonTitle = "Отменить"
        static let deleteButtonTitle = "Удалить"
    }
}


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
