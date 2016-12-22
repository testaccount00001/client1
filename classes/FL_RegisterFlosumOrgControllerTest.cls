@isTest
private class FL_RegisterFlosumOrgControllerTest 
{
    static testMethod void registerApp() 
    {
    	Test.setMock(HttpCalloutMock.class, new FL_FlosumUtil.MockHttpResponseGenerator());
    	Test.setMock(WebServiceMock.class, new FL_FlosumUtil.WebServiceMockImpl());
    	
        FL_RegisterFlosumOrgController controller = new FL_RegisterFlosumOrgController();
        controller.save();
        controller.creds.ConsumerKey__c = 'ConsumerKey__c'; 
        controller.creds.ConsumerSecret__c = 'ConsumerSecret__c';
        controller.save();
        controller.creds.ConsumerKey__c = 'ConsumerKey__c'; 
        controller.creds.ConsumerSecret__c = 'ConsumerSecret__c';
        controller.save();
        controller = new FL_RegisterFlosumOrgController();
        controller.cancel();
        controller.processLogin();
        controller.selectedhostType = controller.GOVT_ORG_PICK_VAL;
        controller.processLogin();
        controller.selectedhostType = controller.SANDBOX_PICK_VAL;
        controller.processLogin();
        Test.startTest();
        controller.checkAndSave();
        controller.userName = 'test@testOrg.com';
        controller.checkAndSave();
        controller.password = 'password';
        controller.checkAndSave();
        Test.stopTest();
    }
    
    static testMethod void updateRegisteredApp() 
    {
    	Test.setMock(HttpCalloutMock.class, new FL_FlosumUtil.MockHttpResponseGenerator());
    	Test.setMock(WebServiceMock.class, new FL_FlosumUtil.WebServiceMockImpl());
    	
    	FL_Flosum_Org__c cred = new FL_Flosum_Org__c();
        cred.Access_Token__c = 'Access_Token__c';
        cred.Instance_URL__c = 'Instance_URL__c';
        cred.Org_Id__c = 'Org_Id__c';
        cred.Refresh_Token__c = 'Refresh_Token__c';
        cred.User_Name__c = 'User_Name__c';
        cred.BranchToCommit__c = 'abc';
        insert cred;
        FL_Credentials__c credentials = new FL_Credentials__c();
        credentials.ConsumerKey__c = 'ConsumerKey__c';
		credentials.ConsumerSecret__c = 'ConsumerSecret__c';
		credentials.Namespace__c = 'Namespace__c';
		credentials.Redirect_URL__c = 'Redirect_URL__c';
		insert credentials;
    	
        FL_RegisterFlosumOrgController controller = new FL_RegisterFlosumOrgController();
        Test.startTest();
        controller.selectedhostType = controller.SANDBOX_PICK_VAL;
        controller.userName = 'test@testOrg.com';
        controller.password = 'password';
        controller.checkAndSave();
        Test.stopTest();
    }
    
    static testMethod void checkAuthentication() 
    {
    	Test.setMock(HttpCalloutMock.class, new FL_FlosumUtil.MockHttpResponseGenerator());
    	Test.setMock(WebServiceMock.class, new FL_FlosumUtil.WebServiceMockImpl());
    	
    	FL_Flosum_Org__c cred = new FL_Flosum_Org__c();
        cred.Access_Token__c = 'Access_Token__c';
        cred.Instance_URL__c = 'Instance_URL__c';
        cred.Org_Id__c = 'Org_Id__c';
        cred.Refresh_Token__c = 'Refresh_Token__c';
        cred.User_Name__c = 'User_Name__c';
        cred.BranchToCommit__c = 'abc';
        insert cred;
        FL_Credentials__c credentials = new FL_Credentials__c();
        credentials.ConsumerKey__c = 'ConsumerKey__c';
		credentials.ConsumerSecret__c = 'ConsumerSecret__c';
		credentials.Namespace__c = 'Namespace__c';
		credentials.Redirect_URL__c = 'Redirect_URL__c';
		insert credentials;
    	
        FL_RegisterFlosumOrgController controller = new FL_RegisterFlosumOrgController();
        Test.startTest();
        controller.checkAuthentication();
        Test.stopTest();
        if(controller.branchOptions.size() > 1)
        	controller.selectedBranch = controller.branchOptions[1].getValue();
        controller.saveBranch();
    }
    
    static testMethod void testRemaining()
    {
    	FL_Flosum_Org__c cred = new FL_Flosum_Org__c();
        cred.Access_Token__c = 'Access_Token__c';
        cred.Instance_URL__c = 'Instance_URL__c';
        cred.Org_Id__c = 'Org_Id__c';
        cred.Refresh_Token__c = 'Refresh_Token__c';
        cred.User_Name__c = 'User_Name__c';
        cred.BranchToCommit__c = 'abc';
        insert cred;
        FL_Credentials__c credentials = new FL_Credentials__c();
        credentials.ConsumerKey__c = 'ConsumerKey__c';
		credentials.ConsumerSecret__c = 'ConsumerSecret__c';
		credentials.Namespace__c = 'Namespace__c';
		credentials.Redirect_URL__c = 'Redirect_URL__c';
		insert credentials;
		
		FL_RegisterFlosumOrgController controller = new FL_RegisterFlosumOrgController();
		controller.convertMessage('This is an error message.');
        Test.startTest();
        controller.selectedhostType = controller.SANDBOX_PICK_VAL;
        controller.userName = 'test@testOrg.com';
        controller.password = 'password';
        controller.checkAndSave();
        Test.setMock(HttpCalloutMock.class, new FL_FlosumUtil.MockHttpResponseGenerator());
        controller.completeRegisterOrg();
        Test.stopTest();
		
    	/*FL_RegisterFlosumOrgController controller = new FL_RegisterFlosumOrgController();
    	controller.convertMessage('This is an error message.');
    	controller.InstanceUrl = 'InstanceUrl';
    	controller.RefereshToken = 'RefereshToken';
    	controller.AccessToken = 'AccessToken';
    	controller.sfid = 'sfid';
    	controller.completeRegisterOrg();*/
    }
}