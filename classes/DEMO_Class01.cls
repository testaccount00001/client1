public with sharing class DEMO_Class01 {

    private final sObject mysObject;
    // The extension constructor initializes the private member
    
    public DEMO_Class01(ApexPages.StandardController stdController) {
        this.mysObject = (sObject)stdController.getRecord();
    }
    public String getRecordName() {
        return 'Hello ' + (String)mysObject.get('name') + ' (' + (Id)mysObject.get('Id') + ')';
    }
}