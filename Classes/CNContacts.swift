//
//  CNContacts.swift
//  Contacts
//
//  Created by Kazuya Ueoka on 2016/05/17.
//  Copyright © 2016年 Timers inc. All rights reserved.
//

import Foundation
import Contacts

@available(iOS 9.0, *)
public final class CNContact {}

@available(iOS 9.0, *)
extension CNContact: FKContactsRequestPermission
{
    public typealias FKContactRequestPermissionCompleteion = (status: FKContactsPermissionResults) -> Void
    public static func requestPermission(completion: FKContactRequestPermissionCompleteion) {
        let status: CNAuthorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        if status == CNAuthorizationStatus.NotDetermined
        {
            let store: CNContactStore = CNContactStore()
            store.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (res, error) in
                if res
                {
                    completion(status: FKContactsPermissionResults.Allowed)
                } else
                {
                    completion(status: FKContactsPermissionResults.Denied)
                }
            })
        } else
        {
            switch status
            {
            case CNAuthorizationStatus.Authorized:
                completion(status: FKContactsPermissionResults.Allowed)
                break
            case CNAuthorizationStatus.Restricted:
                fallthrough
            case CNAuthorizationStatus.Denied:
                completion(status: FKContactsPermissionResults.Denied)
                break
            default:
                break
            }
        }
    }
}

@available(iOS 9.0, *)
extension CNContact: FKContactsProtocol
{
    public static func fetchContacts() throws -> [FKContactItem] {
        var result: [FKContactItem] = []
        let store: CNContactStore = CNContactStore()
        let request: CNContactFetchRequest = CNContactFetchRequest(keysToFetch: [
            CNContactGivenNameKey,
            CNContactFamilyNameKey,
            CNContactPhoneticGivenNameKey,
            CNContactPhoneticFamilyNameKey,
            CNContactEmailAddressesKey
            ])
        do {
            try store.enumerateContactsWithFetchRequest(request) { (contact, stop) in
                contact.emailAddresses.forEach { (labeledValue: CNLabeledValue) in
                    if let emailAddress: String = labeledValue.value as? String
                    {
                        result.append(FKContactItem(lastName: contact.givenName, firstName: contact.familyName, lastKane: contact.phoneticGivenName, firstKana: contact.phoneticFamilyName, email: emailAddress))
                    }
                }
            }
        } catch {
            throw FKContactsErrorType.FetchFailed
        }
        
        return result
    }
}