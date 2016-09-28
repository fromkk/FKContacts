//
//  Contacts.swift
//  Contacts
//
//  Created by Kazuya Ueoka on 2016/05/17.
//  Copyright © 2016年 Timers inc. All rights reserved.
//

import Foundation

public enum FKContactsErrorType: Error
{
    case notAllowed
    case denied
    case fetchFailed
}

public enum FKContactsPermissionResults: Int
{
    case allowed
    case denied
}

public protocol FKContactsRequestPermission
{
    associatedtype FKContactRequestPermissionCompleteion = (_ status: FKContactsPermissionResults) -> Void
    static func requestPermission(_ completion: FKContactRequestPermissionCompleteion) -> Void
}

public final class FKContacts {}

extension FKContacts: FKContactsRequestPermission
{
    public typealias FKContactRequestPermissionCompleteion = (_ status: FKContactsPermissionResults) -> Void
    public static func requestPermission(_ completion: @escaping (FKContactsPermissionResults) -> Void) {
        if #available(iOS 9.0, *) {
            CNContact.requestPermission(completion)
        } else {
            ABContacts.requestPermission(completion)
        }
    }
}

public protocol FKContactsProtocol
{
    static func fetchContacts() throws -> [FKContactItem]
}

extension FKContacts: FKContactsProtocol
{
    public static func fetchContacts() throws -> [FKContactItem] {
        if #available(iOS 9.0, *)
        {
            do {
                return try CNContact.fetchContacts()
            }
        } else
        {
            do {
                return try ABContacts.fetchContacts()
            }
        }
    }
}
