/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import RxSwift
import RxCocoa

class ChocolatesOfTheWorldViewController: UIViewController {
  
  @IBOutlet private var cartButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  let europeanChocolates = Observable.just(Chocolate.ofEurope)
  
  let disposeBag = DisposeBag()
  
  //MARK: View Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Chocolate!!!"
    
    setupCartObserver()
    setupCellConfiguration()
    setupCellTapHandling()
  }
  
  //MARK: Rx Setup
  private func setupCartObserver() {
    
    ShoppingCart.sharedCart.chocolates.asObservable()
      .subscribe(onNext: {
        chocolates in
        self.cartButton.title = "\(chocolates.count) \u{1f36b}"
      })
    .addDisposableTo(disposeBag)
  }
  
  //replacement of numberOfSections and numberOfRows
  private func setupCellConfiguration() {
    europeanChocolates
    .bindTo(tableView //1 - associate the observable
      .rx
      .items(cellIdentifier: ChocolateCell.Identifier,
             cellType: ChocolateCell.self)) { //2 - calls dequeuing methods
              row, chocolate, cell in
              cell.configureWithChocolate(chocolate: chocolate) //3 - configure cell
    }
    .addDisposableTo(disposeBag)
  }
  
  //replaces didSelectRowAt
  private func setupCellTapHandling() {
    tableView
      .rx
      .modelSelected(Chocolate.self) //1 - reactive extension, passing the model and returns an observable
      .subscribe(onNext: { //2 - pass a trailing closure when model is selected
        chocolate in
        ShoppingCart.sharedCart.chocolates.value.append(chocolate) //3 - within closure, add selected to cart
        
        if let selectedRowIndexPath = self.tableView.indexPathForSelectedRow {
          self.tableView.deselectRow(at: selectedRowIndexPath, animated: true) //4 - within closure, tapped row is deselected
        }
      })
    .addDisposableTo(disposeBag)
  }
}

// MARK: - SegueHandler
extension ChocolatesOfTheWorldViewController: SegueHandler {
  
  enum SegueIdentifier: String {
    case
    GoToCart
  }
}
