// SPDX-License-Identifier: MIT
// Copyright @ 2021 Ericom Software.  All Rights Reserved.

protocol WireGuardAppError: Error {
    typealias AlertText = (title: String, message: String)

    var alertText: AlertText { get }
}
