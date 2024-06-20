//
//  Logger.swift
//  
//
//  Created by Frederic DE MATOS on 13/06/2024.
//

import os

public extension Logger {
    private static var subsystem = "4337-sdk"
    static let defaultLogger = Logger(subsystem: subsystem, category: "defaultLogger")
}
