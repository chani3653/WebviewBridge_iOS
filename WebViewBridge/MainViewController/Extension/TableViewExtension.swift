//
//  TableViewExtension.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 3/3/26.
//

import UIKit
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Function List
    
    var functionList: [FunctionItem] {
        let context = BridgeContext(viewController: self, webView: webView)
        return FunctionItem.createFunctionList(context: context)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == functionTableView {
            return functionList.count
        } else if tableView == logTableView {
            return logItems.count
        } else if tableView == storageTableView {
            return storageItems.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == functionTableView {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: FunctionTableViewCell.identifier,
                for: indexPath
            ) as? FunctionTableViewCell else {
                return UITableViewCell()
            }
            
            let function = functionList[indexPath.row]
            cell.configure(with: function.name)
            return cell
        }
        
        if tableView == logTableView {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: LogTableViewCell.identifier,
                for: indexPath
            ) as? LogTableViewCell else {
                return UITableViewCell()
            }
            
            let log = logItems[indexPath.row]
            let isFirst = indexPath.row == 0
            let isLast = indexPath.row == logItems.count - 1
            cell.configure(with: log, isFirst: isFirst, isLast: isLast)
            return cell
        }
        
        if tableView == storageTableView {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: DataTableViewCell.identifier,
                for: indexPath
            ) as? DataTableViewCell else {
                return UITableViewCell()
            }
            
            let item = storageItems[indexPath.row]
            let isFirst = indexPath.row == 0
            let isLast = indexPath.row == storageItems.count - 1
            cell.configure(key: item.key, value: item.value, isFirst: isFirst, isLast: isLast)
            return cell
        }
        
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if tableView == functionTableView {
            let function = functionList[indexPath.row]
            function.action()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == logTableView || tableView == storageTableView {
            return UITableView.automaticDimension
        }
        return 50
    }
}


