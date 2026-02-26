//
//  ActionsTable.swift
//  WebViewBridge
//
//  Created by Chan Hwi Park on 2/26/26.
//
import UIKit

extension BridgeInspectorViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        actions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = actions[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = item.action
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = actions[indexPath.row]

        if item.action == "__emitEvent" {
            let type = item.payload["type"] as? String ?? "event"
            let payload = item.payload["payload"] as? [String: Any] ?? [:]
            logger.log("📣 [EVT->WEB] \(type)\npayload=\(JSONPretty.stringify(payload))")
            outbound.emitEvent(type: type, payload: payload)
            return
        }

        // send request
        let id = UUID().uuidString.lowercased()
        logger.log("➡️ [REQ] \(item.action) id=\(id)\npayload=\(JSONPretty.stringify(item.payload))")

        let req = BridgeRequest(id: id, action: item.action, payload: item.payload)
        outbound.sendRequest(req)
    }
}
