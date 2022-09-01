//
//  DetailTableViewController.swift
//  ToDoListSMD
//
//  Created by Вячеслав Кусакин on 28.07.2022.
//

import UIKit
import CocoaLumberjack

final class DetailViewController: UIViewController {
    override var navigationItem: UINavigationItem {
        let item = UINavigationItem(title: Constants.navigationItemTitle)
        let saveButton = UIBarButtonItem(title: Constants.navigationBarSaveButtonTitle, style: .done, target: self, action: #selector(saveButtonTapped))
        saveButton.setTitleTextAttributes([.foregroundColor: UIColor.ColorAsset.labelTertiary], for: .disabled)
        item.rightBarButtonItem = saveButton
        item.leftBarButtonItem = UIBarButtonItem(title: Constants.navigationBarCancelButtonTitle, style: .plain, target: self, action: #selector(cancelButtonTapped))
        return item
    }

    private var viewModel: DetailViewModelProtocol

    private lazy var scrollView = UIScrollView()
    private lazy var stackView = UIStackView()
    private lazy var textView = UITextView()
    private lazy var tableView = UITableView()
    private lazy var deleteButton = UIButton()

    private lazy var tableViewHeight = NSLayoutConstraint()

    init(_ viewModel: DetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeForKeyBoardNotifications()
        viewModel.assignDelegate(self)

        view.backgroundColor = .ColorAsset.backPrimary
        setupScrollView()
        setupLayout()
        isEnableToSaveOrDelete()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        unsubscribeFromKeyBoardNotifications()
    }

    private func setupScrollView() {
        scrollView.keyboardDismissMode = .interactive
        stackView.axis = .vertical
        stackView.spacing = Constants.stackViewVerticalSpacing
        
        setupTextView()
        setupTableView()
        setupDeleteButton()
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

        // NB: зарефачить
        tableView.register(CellType.deadline.getClass(), forCellReuseIdentifier: CellType.deadline.getClass().cellReuseIdentifier())
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
        view.addSubview(scrollView.forAutoLayouts())
        scrollView.addSubview(stackView.forAutoLayouts())

        stackView.addArrangedSubview(textView.forAutoLayouts())
        stackView.addArrangedSubview(tableView.forAutoLayouts())
        stackView.addArrangedSubview(deleteButton.forAutoLayouts())
        
        tableViewHeight = tableView.heightAnchor.constraint(equalToConstant: Constants.minTableViewHeight)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: Constants.stackViewTopInset),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: Constants.leadingInset),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: Constants.trailingInset),
            stackView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: Constants.stackViewWidthInsets),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.textViewHeight),
            tableViewHeight,
            deleteButton.heightAnchor.constraint(equalToConstant: Constants.deleteButtonHeight)
        ])
    }
}

// MARK: Actions
extension DetailViewController {
    @objc private func deleteButtonTapped() {
        viewModel.deleteTodoItem()
        dismiss(animated: true)
    }

    @objc private func saveButtonTapped() {
        viewModel.saveOrUpdateTodoItem()
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
        viewModel.getNumberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellID = viewModel.getCellID(indexPath)
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? BaseCell else { return UITableViewCell() }
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
extension DetailViewController: DetailViewModelDelegate {
    func showDatePicker() {
        tableView.insertRows(at: [CellType.calendar.getRowIndexPath()], with: .automatic)
        tableViewHeight.constant = tableView.contentSize.height
        animateDatePicker()
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

    func getText() -> String {
        textView.text
    }
}

// MARK: Text view delegate
extension DetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        isEnableToSaveOrDelete()
        scrollView.layoutIfNeeded()
    }
}

// MARK: Keyboards methods
extension DetailViewController {
    private func subscribeForKeyBoardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    private func unsubscribeFromKeyBoardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardHeight = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        let bottomSafeAreaInset = view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = keyboardHeight - bottomSafeAreaInset
        scrollView.verticalScrollIndicatorInsets.bottom = self.scrollView.contentInset.bottom

        guard view.gestureRecognizers == nil else { return }
        addGestureRecognizer(to: view)
    }

    @objc
    private func keyboardWillHide(_ notification: NSNotification) {
        scrollView.contentInset.bottom = .zero
        scrollView.verticalScrollIndicatorInsets.bottom = view.safeAreaInsets.bottom
    }

    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func addGestureRecognizer(to view: UIView) {
        let keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        keyboardDismissTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(keyboardDismissTapGesture)
    }
}

// MARK: Constants
extension DetailViewController {
    private enum Constants {
        static let leadingInset: CGFloat = 16
        static let trailingInset: CGFloat = -16
        static let stackViewTopInset: CGFloat = 16
        static let stackViewWidthInsets: CGFloat = -leadingInset * 2
        static let textViewHeight: CGFloat = 120
        static let minTableViewHeight: CGFloat = 116
        static let stackViewVerticalSpacing: CGFloat = 16
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
