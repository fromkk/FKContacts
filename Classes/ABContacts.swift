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
    public typealias ContactRequestPermissionCompleteion = (_ status: FKContactsPermissionResults) -> Void
    public static func requestPermission(_ completion: @escaping ContactRequestPermissionCompleteion) {
        let status :ABAuthorizationStatus = ABAddressBookGetAuthorizationStatus()
        if status == ABAuthorizationStatus.notDetermined
        {
            ABAddressBookRequestAccessWithCompletion(nil, { (granted, error) in
                DispatchQueue.main.async {
                    if granted
                    {
                        completion(FKContactsPermissionResults.allowed)
                    } else
                    {
                        completion(FKContactsPermissionResults.denied)
                    }
                }
            })
        } else {
            switch status
            {
            case ABAuthorizationStatus.authorized:
                completion(FKContactsPermissionResults.allowed)
                break
            case ABAuthorizationStatus.denied, ABAuthorizationStatus.restricted:
                completion(FKContactsPermissionResults.denied)
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
        let addressBookRef: ABAddressBook = ABAddressBookCreateWithOptions(nil, &err).takeRetainedValue()
        if let _ = err
        {
            throw FKContactsErrorType.fetchFailed
        }

        let tmp: [ABRecord] = ABAddressBookCopyArrayOfAllPeople(addressBookRef).takeRetainedValue() as [ABRecord]
        var result: [FKContactItem] = []
        tmp.forEach { (person: ABRecord) in
            let lastName: String? = ABRecordCopyValue(person, kABPersonLastNameProperty)?.takeRetainedValue() as? String
            let firstName: String? = ABRecordCopyValue(person, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
            let lastKana: String? = ABRecordCopyValue(person, kABPersonLastNamePhoneticProperty)?.takeRetainedValue() as? String
            let firstKana: String? = ABRecordCopyValue(person, kABPersonFirstNamePhoneticProperty)?.takeRetainedValue() as? String

            guard let emailsRef :ABMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty)?.takeRetainedValue() as ABMultiValue? else {
                return
            }
            if 0 < ABMultiValueGetCount(emailsRef)
            {
                if let emails: [String] = ABMultiValueCopyArrayOfAllValues(emailsRef).takeUnretainedValue() as NSArray as? [String]
                {
                    emails.forEach({ (email: String) in
                        result.append(FKContactItem(lastName: lastName, firstName: firstName, lastKana: lastKana, firstKana: firstKana, email: email))
                    })
                }
            }
        }
        return result
    }
}
