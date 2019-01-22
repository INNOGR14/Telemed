//
//  GetCredentials.swift
//  Telemed
//
//  Created by Macbook on 1/13/19.
//  Copyright © 2019 drsocgr14. All rights reserved.
//

import Foundation
import SVProgressHUD
import SCLAlertView

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

class GetCredentials {
    
    
    static func getUserPass() throws -> Credentials {
//        SVProgressHUD.show()
        
        var credentials : Credentials?
        
        let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                    kSecAttrServer as String: Credentials.server,
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        do {
            guard status != errSecItemNotFound else { throw KeychainError.noPassword }
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
            guard let existingItem = item as? [String : Any],
                let passwordData = existingItem[kSecValueData as String] as? Data,
                let password = String(data: passwordData, encoding: String.Encoding.utf8),
                let account = existingItem[kSecAttrAccount as String] as? String
                else {
                    throw KeychainError.unexpectedPasswordData
            }
            credentials = Credentials(username: account, password: password)
        
        } catch {
            print(error)
//            SCLAlertView().showNotice("You're not signed in", subTitle: "Please sign in")
        }
//        SVProgressHUD.dismiss()
        if let credentials = credentials {
            return credentials
        }
        else {
            return Credentials(username: "none", password: "none")
        }
    }
    
}
