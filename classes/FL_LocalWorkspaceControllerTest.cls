@isTest
private class FL_LocalWorkspaceControllerTest
{
	static testMethod void createTempRecordsForCommitTest()
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
        Test.startTest();
		FL_LocalWorkspaceController controller = new FL_LocalWorkspaceController();
		controller.checkAuthentication();
		controller.createLog();
		FL_LocalWorkspaceController.CommitWraper wrap = new FL_LocalWorkspaceController.CommitWraper();
		wrap.fullNames = new List<String>{'ClassA','ClassB','PageA','PageB'};
		wrap.metaTypes = new List<String>{'ApexClass','ApexPage'};
		wrap.dataMap = new Map<String,FL_LocalWorkspaceController.CompDetailWraper>();
		for(String fullName : wrap.fullNames)
		{
			FL_LocalWorkspaceController.CompDetailWraper wrapInfo = new FL_LocalWorkspaceController.CompDetailWraper();
			wrapInfo.fullName = fullName;  
	    	wrapInfo.fileName = fullName;
	    	wrapInfo.metaType = fullName.startsWith('Class') ? wrap.metaTypes[0] : wrap.metaTypes[1];
	    	wrapInfo.crcCode = '12345';
	    	wrapInfo.lastModifiedDate = '2015-05-14T13:35:17.000Z';
	    	wrapInfo.lastModifiedByName = 'User Name';
	    	wrapInfo.base64Content = EncodingUtil.base64Encode(Blob.valueOf('Content{}'));
	    	wrap.dataMap.put(wrapInfo.metaType+'#'+wrapInfo.fullName,wrapInfo);
		}
		controller.commitStr = JSON.serialize(wrap);
		controller.createTempRecordsForCommit();
		controller.syncName = 'syncName';
		controller.createSyncLog();
		System.assert(controller.syncId != null && controller.syncId.length() == 18);
		Test.stopTest();
	}
	
	static testMethod void commitTest()
	{
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
		
		FL_LocalWorkspaceController controller = new FL_LocalWorkspaceController();
		controller.createLog();
		FL_LocalWorkspaceController.CommitWraper wrap = new FL_LocalWorkspaceController.CommitWraper();
		wrap.fullNames = new List<String>{'ClassA','ClassB','PageA','PageB'};
		wrap.metaTypes = new List<String>{'ApexClass','ApexPage'};
		wrap.dataMap = new Map<String,FL_LocalWorkspaceController.CompDetailWraper>();
		for(String fullName : wrap.fullNames)
		{
			FL_LocalWorkspaceController.CompDetailWraper wrapInfo = new FL_LocalWorkspaceController.CompDetailWraper();
			wrapInfo.fullName = fullName;  
	    	wrapInfo.fileName = fullName;
	    	wrapInfo.metaType = fullName.startsWith('Class') ? wrap.metaTypes[0] : wrap.metaTypes[1];
	    	wrapInfo.crcCode = '12345';
	    	wrapInfo.lastModifiedDate = '2015-05-14T13:35:17.000Z';
	    	wrapInfo.lastModifiedByName = 'User Name';
	    	wrapInfo.base64Content = EncodingUtil.base64Encode(Blob.valueOf('Content{}'));
	    	wrap.dataMap.put(wrapInfo.metaType+'#'+wrapInfo.fullName,wrapInfo);
		}
		controller.commitStr = JSON.serialize(wrap);
		controller.createTempRecordsForCommit();
		controller.syncName = 'syncName';
		controller.createSyncLog();
		List<FL_LocalWorkspaceController.CommitStatusWraper> detailLi = FL_LocalWorkspaceController.getCommitDetail(controller.logId);
		List<String> compLogIds = new List<String>();
		for(FL_LocalWorkspaceController.CommitStatusWraper detail : detailLi)
		{
			compLogIds.add(detail.compId);
		}
		Test.startTest();
		
		FL_LocalWorkspaceController.commitComponents(compLogIds,controller.syncId);
		controller.finishCommit();
		System.assert(controller.syncId != null && controller.syncId.length() == 18);
		Test.stopTest();
	}
	
	static testMethod void checkCRCTest()
	{
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
        
        Test.startTest();
		
		FL_LocalWorkspaceController.checkCrcCodeFromFlosum('123');
		FL_Credentials__c credTest = FL_Credentials__c.getOrgDefaults();
		System.assert(credTest != null && credTest.Id != null);
		Test.stopTest();
	}

	static testMethod void testFirstStepMerge()
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

        FL_Upload_Log__c upLog = new FL_Upload_Log__c();
        insert upLog;

        FL_Upload_Manifest__c upMan = new FL_Upload_Manifest__c();
        upMan.Component_Name__c = 'PageA';
        upMan.Component_Type__c = 'ApexPage';
        upMan.Commit_Status__c = 'Safe To Commit';
        upMan.Changed_By__c = 'Test user';
        upMan.Changed_On__c = DateTime.valueOf('2016-07-29 03:28:13 GMT');
        upMan.Reason__c = 'Same as Version 1.00 in Repository';
        upMan.Upload_Log__c = upLog.Id;
        insert upMan;

        FL_Upload_Manifest__c upMan2 = new FL_Upload_Manifest__c();
        upMan2.Component_Name__c = 'PageB';
        upMan2.Component_Type__c = 'ApexPage';
        upMan2.Commit_Status__c = 'Safe To Commit';
        upMan2.Changed_By__c = 'Test user';
        upMan2.Changed_On__c = DateTime.valueOf('2016-07-29 03:28:13 GMT');
        upMan2.Reason__c = 'Same as Version 1.00 in Repository';
        upMan2.Upload_Log__c = upLog.Id;
        insert upMan2;

        Attachment att = new Attachment();
        att.ParentId = upMan.Id;
        att.Body = Blob.valueOf('text');
        att.Name = upMan.Component_Name__c;
        insert att;

        String stringId = upLog.Id;
		List<String> selectListId = new List<String>{upMan2.Id,upMan2.Id};
		String stringListBranch ='[{'+
			'"compCRC":"-2018352022 -260042129",'+
			'"compId":"a0D2C000000L52RUAS",'+
			'"compName":"PageA",'+
			'"compType":"ApexPage",'+
			'"hisId":"a0C2C000000L7VXUA0",'+
			'"reason":"Same as Version 1.00 in Repository",'+
			'"version":1},'+
			'{"compCRC":"455427761 1987776519",'+
			'"compId":"a0D2C000000L52WUAS",'+
			'"compName":"PageB",'+
			'"compType":"ApexPage",'+
			'"hisId":"a0C2C000000L7VcUAK",'+
			'"reason":"Same as Version 1.00 in Repository",'+
			'"version":1}]';

        Test.startTest();
		FL_LocalWorkspaceController controller = new FL_LocalWorkspaceController();
		//controller.checkAuthentication();
		//controller.createLog();
		//FL_LocalWorkspaceController.CommitWraper wrap = new FL_LocalWorkspaceController.CommitWraper();
		//wrap.fullNames = new List<String>{'PageA','PageB'};
		//wrap.metaTypes = new List<String>{'ApexPage'};
		//wrap.dataMap = new Map<String,FL_LocalWorkspaceController.CompDetailWraper>();
		//for(String fullName : wrap.fullNames)
		//{
		//	FL_LocalWorkspaceController.CompDetailWraper wrapInfo = new FL_LocalWorkspaceController.CompDetailWraper();
		//	wrapInfo.fullName = fullName;  
	 //   	wrapInfo.fileName = fullName;
	 //   	wrapInfo.metaType = 'ApexPage';
	 //   	wrapInfo.crcCode = '12345';
	 //   	wrapInfo.lastModifiedDate = '2015-05-14T13:35:17.000Z';
	 //   	wrapInfo.lastModifiedByName = 'User Name';
	 //   	wrapInfo.base64Content = EncodingUtil.base64Encode(Blob.valueOf('Content{}'));
	 //   	wrap.dataMap.put(wrapInfo.metaType+'#'+wrapInfo.fullName,wrapInfo);
		//}
		//controller.commitStr = JSON.serialize(wrap);
        FL_LocalWorkspaceController.FirstStepMerge(stringId, selectListId, stringListBranch);
        Test.stopTest();
    }

    static testMethod void testComponentsRemoteRepository()
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

        Test.startTest();
        FL_LocalWorkspaceController controller = new FL_LocalWorkspaceController();
        FL_LocalWorkspaceController.getComponentsRemoteRepository('00P2C000000UWi6UAG','a0D2C000000L52wUAC');
        Test.stopTest();
    }

    static testMethod void testMergeComponents()
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

        FL_Upload_Log__c upLog = new FL_Upload_Log__c();
        insert upLog;

        FL_Upload_Manifest__c upMan = new FL_Upload_Manifest__c();
        upMan.Component_Name__c = 'PageA';
        upMan.Component_Type__c = 'ApexPage';
        upMan.Commit_Status__c = 'Safe To Commit';
        upMan.Changed_By__c = 'Test user';
        upMan.Changed_On__c = DateTime.valueOf('2016-07-29 03:28:13 GMT');
        upMan.Reason__c = 'Same as Version 1.00 in Repository';
        upMan.Upload_Log__c = upLog.Id;
        insert upMan;


        Test.startTest();
        FL_LocalWorkspaceController controller = new FL_LocalWorkspaceController();
        FL_LocalWorkspaceController.mergeComponents(upLog.Id);
        FL_LocalWorkspaceController.mergeComponents('00P2C000000UWi6UAG');
        Test.stopTest();
    }

    static testMethod void testUpdateMergeFile()
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

        FL_Upload_Log__c upLog = new FL_Upload_Log__c();
        insert upLog;

        FL_Upload_Manifest__c upMan = new FL_Upload_Manifest__c();
        upMan.Component_Name__c = 'PageA';
        upMan.Component_Type__c = 'ApexPage';
        upMan.Commit_Status__c = 'Safe To Commit';
        upMan.Changed_By__c = 'Test user';
        upMan.Changed_On__c = DateTime.valueOf('2016-07-29 03:28:13 GMT');
        upMan.Reason__c = 'Same as Version 1.00 in Repository';
        upMan.Upload_Log__c = upLog.Id;
        insert upMan;

        Attachment att = new Attachment();
        att.ParentId = upMan.Id;
        att.Body = Blob.valueOf('text');
        att.Name = upMan.Component_Name__c;
        insert att;

        List<List<String>> listAttach = new List<List<String>>();
        List<String> attach = new List<String>();
        String doby = 'UEsDBAoAAAAIAFeK/UgUfkYdhQAAAMwAAAAQAAAAcGFnZXMvUGFnZTcucGFnZbNJLEitsCpITE9VsONSULBR1NVVcEpNz8xTcElNSyzNKVFwzs8rSc0rUQhy9fUPc1UI8fAMVtDVBSvOMLQDyqYXJZaU5iSWZObnFdvoA8WAUiEZmcUKQFSZX1qkkJdarhAAtAFmvmteChGm+wF1+WTmpRoisY2Q2Mb6+iYmXDb6cA/YAQBQSwMECgAAAAgAV4r9SBR+Rh2FAAAAzAAAABkAAABwYWdlcy9QYWdlNy5wYWdlLW1ldGEueG1ss0ksSK2wKkhMT1Ww41JQsFHU1VVwSk3PzFNwSU1LLM0pUXDOzytJzStRCHL19Q9zVQjx8AxW0NUFK84wtAPKphcllpTmJJZk5ucV2+gDxYBSIRmZxQpAVJlfWqSQl1quEAC0AWa+a14KEab7AXX5ZOalGiKxjZDYxvr6JiZcNvpwD9gBAFBLAQIUAAoAAAAIAFeK/UgUfkYdhQAAAMwAAAAQAAAAAAAAAAAAAAAAAAAAAABwYWdlcy9QYWdlNy5wYWdlUEsBAhQACgAAAAgAV4r9SBR+Rh2FAAAAzAAAABkAAAAAAAAAAAAAAAAAswAAAHBhZ2VzL1BhZ2U3LnBhZ2UtbWV0YS54bWxQSwUGAAAAAAIAAgCFAAAAbwEAAAAA';
        String atId = att.Id;
        attach.add(doby);
        attach.add(atId);
        attach.add('466098272');
        listAttach.add(attach);

        Test.startTest();
        FL_LocalWorkspaceController controller = new FL_LocalWorkspaceController();
        FL_LocalWorkspaceController.updateMergeFile(listAttach);
        Test.stopTest();
    }

    static testMethod void testBranchItems()
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

        FL_Upload_Log__c upLog = new FL_Upload_Log__c();
        insert upLog;

        FL_Upload_Manifest__c upMan = new FL_Upload_Manifest__c();
        upMan.Component_Name__c = 'PageA';
        upMan.Component_Type__c = 'ApexPage';
        upMan.Commit_Status__c = 'Safe To Commit';
        upMan.Changed_By__c = 'Test user';
        upMan.Changed_On__c = DateTime.valueOf('2016-07-29 03:28:13 GMT');
        upMan.Reason__c = 'Same as Version 1.00 in Repository';
        upMan.Upload_Log__c = upLog.Id;
        insert upMan;

        Attachment att = new Attachment();
        att.ParentId = upMan.Id;
        att.Body = Blob.valueOf('text');
        att.Name = upMan.Component_Name__c;
        insert att;

        String jsonString = '[{'+
        	'"compName":"PageA",'+
            '"compType":"ApexPage",'+
            '"version":1}]';

        List<List<String>> listAttach = new List<List<String>>();
        List<String> attach = new List<String>();
        String doby = 'UEsDBAoAAAAIAFeK/UgUfkYdhQAAAMwAAAAQAAAAcGFnZXMvUGFnZTcucGFnZbNJLEitsCpITE9VsONSULBR1NVVcEpNz8xTcElNSyzNKVFwzs8rSc0rUQhy9fUPc1UI8fAMVtDVBSvOMLQDyqYXJZaU5iSWZObnFdvoA8WAUiEZmcUKQFSZX1qkkJdarhAAtAFmvmteChGm+wF1+WTmpRoisY2Q2Mb6+iYmXDb6cA/YAQBQSwMECgAAAAgAV4r9SBR+Rh2FAAAAzAAAABkAAABwYWdlcy9QYWdlNy5wYWdlLW1ldGEueG1ss0ksSK2wKkhMT1Ww41JQsFHU1VVwSk3PzFNwSU1LLM0pUXDOzytJzStRCHL19Q9zVQjx8AxW0NUFK84wtAPKphcllpTmJJZk5ucV2+gDxYBSIRmZxQpAVJlfWqSQl1quEAC0AWa+a14KEab7AXX5ZOalGiKxjZDYxvr6JiZcNvpwD9gBAFBLAQIUAAoAAAAIAFeK/UgUfkYdhQAAAMwAAAAQAAAAAAAAAAAAAAAAAAAAAABwYWdlcy9QYWdlNy5wYWdlUEsBAhQACgAAAAgAV4r9SBR+Rh2FAAAAzAAAABkAAAAAAAAAAAAAAAAAswAAAHBhZ2VzL1BhZ2U3LnBhZ2UtbWV0YS54bWxQSwUGAAAAAAIAAgCFAAAAbwEAAAAA';
        String atId = att.Id;
        attach.add(doby);
        attach.add(atId);
        listAttach.add(attach);

        List<Id> tempList = new List<Id>();
        Test.startTest();
        FL_LocalWorkspaceController controller = new FL_LocalWorkspaceController();
        FL_LocalWorkspaceController.getBranchItems(upLog.Id, jsonString);
        FL_LocalWorkspaceController.getAttachmentsRemoteBranchID(tempList);
        Test.stopTest();
    }
}