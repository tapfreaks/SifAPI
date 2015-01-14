//
//  Globals.swift
//  Paid App
//
//  Created by IOS Developer on 12/28/14.
//  Copyright (c) 2014 TapFreaks.NeT. All rights reserved.
//

// Variables
public var selectedLanguage = 0

// Functions
public func langSlug() -> String {
    var rString = "_en"
    switch selectedLanguage {
    case 0:
        rString = "_en";
        break
    case 1:
        rString = "_ar";
        break
    case 2:
        rString = "_fr";
        break
    case 3:
        rString = "_hn";
        break
    case 4:
        rString = "_ur";
        break
    case 5:
        rString = "_ba";
        break
    case 6:
        rString = "_ph";
        break
    default:
        rString = "_en";
        break
    }
    return rString;
}

