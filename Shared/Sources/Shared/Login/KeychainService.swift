//
//  KeychainService.swift
//  
//
//  Created by Jannis Mainczyk on 17.06.21.
//
//  Source: https://www.advancedswift.com/secure-private-data-keychain-swift/

import Foundation

// MARK: - KeychainService
/**
 Read & write credentials to the iOS keychain.

 Example: Save `token` to keychain and read it again

     KeychainService.save(key: "token", value: token)
     var keychainToken = KeychainService.read(key: "token")

*/
public enum KeychainService {
    enum KeychainError: Error {
        // Attempted read for an item that does not exist.
        case itemNotFound

        // Attempted save to override an existing item.
        // Use update instead of save to update existing items
        case duplicateItem

        // A read of an item in any format other than Data
        case invalidItemFormat

        // Any operation result status than errSecSuccess
        case unexpectedStatus(OSStatus)
    }

    // MARK: - Convenience Methods
    static var keychainServiceName = "tumsm"

    /**
     Save string to keychain

     - Parameters:
         - key: name of the value to save. You can retrieve the value from the keychain using this name.
         - value: value to save to keychain.

     - Note:
         - If `key` already exists, it's value will be updated.
         - `value` may only contain UTF-8 characters
    */
    public static func save(key: String, value: String) {
        guard let valueData = value.data(using: .utf8) else {
            print("Couldn't encode value!")
            return
        }

        do {
            try KeychainService.save(password: valueData, service: keychainServiceName, account: key)
            print("'\(key): \(value)' successfully saved to keychain!")
        } catch KeychainService.KeychainError.duplicateItem {
            print("A value for this key already exists! Updating existing key.")
            do {
                try KeychainService.update(password: valueData, service: keychainServiceName, account: key)
                print("'\(key)' successfully updated in keychain! New value: \(value)")
            } catch {
                print("Error updating '\(key)' in keychain!")
            }
        } catch {
            print("Error saving '\(key)' to keychain!")
        }
    }

    /**
     Read string from keychain

     - Parameters:
         - key: name of the value to retrieve.

     - Note:
         - If `key` already exists, it's value will be updated.
         - The returned `String` will only contain UTF-8 characters

     - Returns: Value for `key` that was previously saved to keychain
    */
    public static func read(key: String) -> String? {
        do {
            let data = try read(service: keychainServiceName, account: key)
            guard let dataString = String(data: data, encoding: .utf8) else {
                print("Error when decoding value of \(key)!")
                return nil
            }
            return dataString
        } catch {
            print("Error reading \(key) from keychain!")
            return nil
        }
    }

    /// Delete key-value pair from keychain.
    public static func delete(key: String) {
        do {
            try delete(service: keychainServiceName, account: key)
        } catch {
            print("Error deleting \(key) from keychain!")
        }
    }

    // MARK: - save
    static func save(password: Data, service: String, account: String) throws {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to save in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,

            // kSecValueData is the item value to save
            kSecValueData as String: password as AnyObject
        ]

        // SecItemAdd attempts to add the item identified by
        // the query to keychain
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )

        // errSecDuplicateItem is a special case where the
        // item identified by the query already exists. Throw
        // duplicateItem so the client can determine whether
        // or not to handle this as an error
        if status == errSecDuplicateItem {
            throw KeychainError.duplicateItem
        }

        // Any status other than errSecSuccess indicates the
        // save operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: update
    static func update(password: Data, service: String, account: String) throws {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to update in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]

        // attributes is passed to SecItemUpdate with
        // kSecValueData as the updated item value
        let attributes: [String: AnyObject] = [
            kSecValueData as String: password as AnyObject
        ]

        // SecItemUpdate attempts to update the item identified
        // by query, overriding the previous value
        let status = SecItemUpdate(
            query as CFDictionary,
            attributes as CFDictionary
        )

        // errSecItemNotFound is a special status indicating the
        // item to update does not exist. Throw itemNotFound so
        // the client can determine whether or not to handle
        // this as an error
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        // Any status other than errSecSuccess indicates the
        // update operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }

    // MARK: read
    static func read(service: String, account: String) throws -> Data {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to read in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,

            // kSecMatchLimitOne indicates keychain should read
            // only the most recent item matching this query
            kSecMatchLimit as String: kSecMatchLimitOne,

            // kSecReturnData is set to kCFBooleanTrue in order
            // to retrieve the data for the item
            kSecReturnData as String: kCFBooleanTrue
        ]

        // SecItemCopyMatching will attempt to copy the item
        // identified by query to the reference itemCopy
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &itemCopy
        )

        // errSecItemNotFound is a special status indicating the
        // read item does not exist. Throw itemNotFound so the
        // client can determine whether or not to handle
        // this case
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }

        // Any status other than errSecSuccess indicates the
        // read operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }

        // This implementation of KeychainInterface requires all
        // items to be saved and read as Data. Otherwise,
        // invalidItemFormat is thrown
        guard let password = itemCopy as? Data else {
            throw KeychainError.invalidItemFormat
        }

        return password
    }

    // MARK: delete
    static func delete(service: String, account: String) throws {
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to delete in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]

        // SecItemDelete attempts to perform a delete operation
        // for the item identified by query. The status indicates
        // if the operation succeeded or failed.
        let status = SecItemDelete(query as CFDictionary)

        // Any status other than errSecSuccess indicates the
        // delete operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}
