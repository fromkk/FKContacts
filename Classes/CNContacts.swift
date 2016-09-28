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
    public typealias FKContactRequestPermissionCompleteion = (_ status: FKContactsPermissionResults) -> Void
    public static func requestPermission(_ completion: @escaping FKContactRequestPermissionCompleteion) {
        let status: CNAuthorizationStatus = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        if status == CNAuthorizationStatus.notDetermined
        {
            let store: CNContactStore = CNContactStore()
            store.requestAccess(for: CNEntityType.contacts, completionHandler: { (res, error) in
                if res
                {
                    completion(FKContactsPermissionResults.allowed)
                } else
                {
                    completion(FKContactsPermissionResults.denied)
                }
            })
        } else
        {
            switch status
            {
            case CNAuthorizationStatus.authorized:
                completion(FKContactsPermissionResults.allowed)
                break
            case CNAuthorizationStatus.restricted:
                fallthrough
            case CNAuthorizationStatus.denied:
                completion(FKContactsPermissionResults.denied)
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
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneticGivenNameKey as CNKeyDescriptor,
            CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor
            ])
        do {
            try store.enumerateContacts(with: request) { (contact, stop) in
                contact.emailAddresses.forEach { (labeledValue: CNLabeledValue) in
                    if let emailAddress: String = labeledValue.value as? String
                    {
                        result.append(FKContactItem(lastName: contact.givenName, firstName: contact.familyName, lastKana: contact.phoneticGivenName, firstKana: contact.phoneticFamilyName, email: emailAddress))
                    }
                }
            }
        } catch {
            throw FKContactsErrorType.fetchFailed
        }
        
        return result
    }
}
