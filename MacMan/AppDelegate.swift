//
//  AppDelegate.swift
//  MacMan
//
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: CognitoRegionType, identityPoolId: CognitoIdentityPoolId)
        
        let defaultServiceConfiguration = AWSServiceConfiguration(
            region: DefaultServiceRegionType, credentialsProvider: credentialsProvider)
        
        AWSServiceManager.defaultServiceManager().defaultServiceConfiguration = defaultServiceConfiguration
        
        return true
    }
}

