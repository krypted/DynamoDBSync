//
//  MMDynamoDBManager.swift
//  MacMan
//
//
//

import Foundation

class MMDynamoDBManger: NSObject {
    class func describeTable() -> AWSTask {
        let dynamoDB = AWSDynamoDB.defaultDynamoDB()
        
        let describeTableInput = AWSDynamoDBDescribeTableInput()
        describeTableInput.tableName = MacManDynamoDBTableName
        return dynamoDB.describeTable(describeTableInput)
    }
}

class MMTableRow: AWSDynamoDBObjectModel, AWSDynamoDBModeling  {
    
    var Version:String?
    var Command:String?
    var Manual:String?
    
    class func dynamoDBTableName() -> String! {
        return MacManDynamoDBTableName
    }
    
    class func hashKeyAttribute() -> String! {
        return "Version"
    }
    
    class func rangeKeyAttribute() -> String! {
        return "Command"
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        return super.isEqual(object)
    }
    
    override func `self`() -> Self {
        return self
    }
}

