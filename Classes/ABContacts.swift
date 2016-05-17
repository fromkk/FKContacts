//
//  ABContacts.swift
//  Contacts
//
//  Created by Kazuya Ueoka on 2016/05/17.
//  Copyright © 2016年 Timers inc. All rights reserved.
//

import Foundation
import AddressBook

public final class ABContacts {}

extension ABContacts: FKContactsRequestPermission
{
    public typealias ContactRequestPermissionCompleteion = (status: FKContactsPermissionResults) -> Void
    public static func requestPermission(completion: ContactRequestPermissionCompleteion) {
        let status :ABAuthorizationStatus = ABAddressBookGetAuthorizationStatus()
        if status == ABAuthorizationStatus.NotDetermined
        {
            ABAddressBookRequestAccessWithCompletion(nil, { (granted, error) in
                if granted
                {
                    completion(status: FKContactsPermissionResults.Allowed)
                } else
                {
                    completion(status: FKContactsPermissionResults.Denied)
                }
            })
        } else {
            switch status
            {
            case ABAuthorizationStatus.Authorized:
                completion(status: FKContactsPermissionResults.Allowed)
                break
            case ABAuthorizationStatus.Denied:
                fallthrough
            case ABAuthorizationStatus.Restricted:
                completion(status: FKContactsPermissionResults.Denied)
                break
            default:
                break
            }

        }
    }
}

extension ABContacts: FKContactsProtocol
{
    public static func fetchContacts() throws -> [FKContactItem] {
        var err : Unmanaged<CFError>? = nil
        let addressBookRef: ABAddressBookRef? = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if let _ = err
        {
            throw FKContactsErrorType.FetchFailed
        }
        
        
        let tmp: [ABRecordRef] = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as [ABRecordRef]
        var result: [FKContactItem] = []
        tmp.forEach { (person: ABRecordRef) in
            let lastName: String? = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String
            let firstName: String? = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
            let lastKana: String? = ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty)?.takeRetainedValue() as? String
            let firstKana: String? = ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty)?.takeRetainedValue() as? String
            
            let emailsRef :ABMultiValueRef = ABRecordCopyValue(person, kABPersonEmailProperty).takeRetainedValue() as ABMultiValueRef
            if 0 < ABMultiValueGetCount(emailsRef)
            {
                if let emails: [String] = ABMultiValueCopyArrayOfAllValues(emailsRef).takeUnretainedValue() as NSArray as? [String]
                {
                    emails.forEach({ (email: String) in
                        result.append(FKContactItem(lastName: lastName, firstName: firstName, lastKane: lastKana, firstKana: firstKana, email: email))
                    })
                }
            }
        }
        return result
    }
}