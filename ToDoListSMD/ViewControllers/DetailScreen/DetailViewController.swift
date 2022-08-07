//
//  DetailTableViewController.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 28.07.2022.
//

import UIKit

protocol DetailViewControllerDelegate {
    func showDatePicker()
    func hideDatePicker()
    func animateDatePicker()
}

final class DetailViewController: UIViewController {
    var viewModel: DetailViewModelProtocol!

    override var navigationItem: UINavigationItem {
        let item = UINavigationItem(title: Constants.navigationItemTitle)
        let saveButton = UIBarButtonItem(title: Constants.navigationBarSaveButtonTitle, style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.setTitleTextAttributes([.foregroundColor: UIColor.ColorAsset.labelTertiary!], for: .disabled)
        item.rightBarButtonItem = saveButton
        item.leftBarButtonItem = UIBarButtonItem(title: Constants.navigationBarCancelButtonTitle, style: .plain, target: self, action: #selector(cancelButtonTapped))
        return item
    }

    private lazy var scrollView = UIScrollView()
    private lazy var textView = UITextView()
    private lazy var tableView = UITableView()
    private lazy var deleteButton = UIButton()

    private lazy var tableViewHeight = NSLayoutConstraint()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyBoardNotifications()
        viewModel.delegate = self

        view.backgroundColor = .ColorAsset.backPrimary
        setupScrollView()
        setupLayout()
        isEnableToSaveOrDelete()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
        textView.backgroundColor = .ColorAsset.backSecondary
        textView.layer.cornerRadius = Constants.radius
        textView.textContainer.lineFragmentPadding = Constants.textContainerLineFragmentPadding
        textView.textContainerInset = UIEdgeInsets(
            top: Constants.textContainerTopInset,
            left: Constants.textContainerLeftInset,
            bottom: Constants.textContainerBottomInset,
            right: Constants.textContainerRightInset
        )
        textView.textColor = .ColorAsset.labelPrimary
        textView.font = .FontAsset.body
        textView.text = viewModel.text
        textView.isScrollEnabled = false
        textView.delegate = self
    }

    private func setupTableView() {
        tableView.layer.cornerRadius = Constants.radius
        tableView.separatorColor = .ColorAsset.supportSeparator
        tableView.separatorInset = UIEdgeInsets(
            top: Constants.separatorTopInset,
            left: Constants.separatorLeftInset,
            bottom: Constants.separatorBottomInset,
            right: Constants.separatorRightInset
        )
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self

        //NB: зарефачить
        tableView.register(CellType.deadLine.getClass(), forCellReuseIdentifier: CellType.deadLine.getClass().cellReuseIdentifier())
        tableView.register(CellType.importance.getClass(), forCellReuseIdentifier: CellType.importance.getClass().cellReuseIdentifier())
        tableView.register(CellType.calendar.getClass(), forCellReuseIdentifier: CellType.calendar.getClass().cellReuseIdentifier())
    }

    private func setupDeleteButton() {
        deleteButton.backgroundColor = .ColorAsset.backSecondary
        deleteButton.layer.cornerRadius = Constants.radius
        deleteButton.setTitleColor(.ColorAsset.labelTertiary, for: .disabled)
        deleteButton.setTitleColor(.ColorAsset.colorRed, for: .normal)
        deleteButton.setTitle(Constants.deleteButtonTitle, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
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

// MARK: Actions
extension DetailViewController {
    @objc private func deleteButtonTapped() {
        viewModel.deleteTodoItem()
        dismiss(animated: true)
    }

    @objc private func saveButtonTapped() {
        viewModel.saveTodoItem()
        dismiss(animated: true)
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    private func isEnableToSaveOrDelete() {
        let status = textView.hasText
        navigationController?.navigationBar.topItem?.rightBarButtonItem?.isEnabled = status
        deleteButton.isEnabled = status
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

// MARK: Detail view controller delegate
extension DetailViewController: DetailViewControllerDelegate {
    func showDatePicker() {
        tableView.insertRows(at: [CellType.calendar.getRowIndexPath()], with: .automatic)
        tableViewHeight.constant = tableView.contentSize.height
    }

    func hideDatePicker() {
        tableView.deleteRows(at: [CellType.calendar.getRowIndexPath()], with: .automatic)
        tableViewHeight.constant = Constants.minTableViewHeight
    }

    func animateDatePicker() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.scrollView.layoutIfNeeded()
        }
    }
}

// MARK: Text view delegate
extension DetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        isEnableToSaveOrDelete()
    }
}

//MARK: Keyboards methods
extension DetailViewController {
    private func registerForKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(kbWillHIde), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func kbWillShow(_ notification: NSNotification) {
        guard let kbFrameSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardTopY = kbFrameSize.cgRectValue.origin.y
        let convertedDeleteButtonFrame = view.convert(deleteButton.frame, from: deleteButton.superview)
        let deleteButtonBottomY = convertedDeleteButtonFrame.origin.y + deleteButton.frame.height
        guard deleteButtonBottomY > keyboardTopY else { return }
        let newFrameY = (keyboardTopY - deleteButtonBottomY - Constants.appearedKeyBoardInset)
        scrollView.contentOffset.y = -newFrameY
    }

    @objc func kbWillHIde(_ notification: NSNotification) {
        scrollView.contentOffset.y = 0
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
        static let separatorBottomInset: CGFloat = 0
        static let separatorLeftInset: CGFloat = 16
        static let separatorRightInset: CGFloat = 0
        static let deleteButtonHeight: CGFloat = 56
        static let radius: CGFloat = 16
        static let animationDuration: CGFloat = 0.5
        static let appearedKeyBoardInset: CGFloat = 15
        static let navigationItemTitle = "Дело"
        static let navigationBarSaveButtonTitle = "Сохранить"
        static let navigationBarCancelButtonTitle = "Отменить"
        static let deleteButtonTitle = "Удалить"
    }
}
