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
        var result: [FKContactItem] = []

        return result
    }
}