//
//  Contacts.swift
//  Contacts
//
//  Created by Kazuya Ueoka on 2016/05/17.
//  Copyright © 2016年 Timers inc. All rights reserved.
//

import Foundation

public enum FKContactsErrorType: ErrorType
{
    case NotAllowed
    case Denied
    case FetchFailed
}

public enum FKContactsPermissionResults: Int
{
    case Allowed
    case Denied
}

public protocol FKContactsRequestPermission
{
    associatedtype FKContactRequestPermissionCompleteion = (status: FKContactsPermissionResults) -> Void
    static func requestPermission(completion: FKContactRequestPermissionCompleteion) -> Void
}

public final class FKContacts {}

extension FKContacts: FKContactsRequestPermission
{
    public typealias FKContactRequestPermissionCompleteion = (status: FKContactsPermissionResults) -> Void
    public static func requestPermission(completion: FKContactRequestPermissionCompleteion) {
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