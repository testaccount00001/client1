@isTest
private class FL_RemoteRepositoryControllerTest 
{
    static testMethod void authenticationTest() 
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
        FL_RemoteRepositoryController controller = new FL_RemoteRepositoryController();
        controller.checkAuthentication();
        Test.stopTest();
    }
    
    static testMethod void getRepoComponentsTest()
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
        FL_RemoteRepositoryController controller = new FL_RemoteRepositoryController();
        FL_RemoteRepositoryController.getComponents('',System.now().formatGMT('yyyy-MM-dd hh:mm:ss '));
        Test.stopTest();
    }
    
    static testMethod void testRepositoryComponent()
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
        FL_RemoteRepositoryController controller = new FL_RemoteRepositoryController();
        controller.checkAuthentication();
        List<FL_RemoteRepositoryController.DonwnloadCompWraper> wrapLi = new List<FL_RemoteRepositoryController.DonwnloadCompWraper>();
        FL_RemoteRepositoryController.DonwnloadCompWraper wrap = new FL_RemoteRepositoryController.DonwnloadCompWraper();
        wrap.Status = FL_LocalFlosumConstants.SAFE_TO_COMMIT;
        wrap.changedBy = 'User';
        wrap.changedOn = '2015-05-14 13:35:17.000Z';
        wrap.committedBy = 'User';
        wrap.committedOn = '2015-05-14 13:35:17.000Z';
        wrap.compCRC = '2345';
        wrap.compName = 'ClassA';
        wrap.compType = 'ApexClass';
        wrap.fileName = 'class/ClassA.cls';
        wrapLi.add(wrap);
        String syncJSON = JSON.serialize(wrapLi);
        controller.logRecordId = FL_RemoteRepositoryController.createSyncRecords('',syncJSON,'sync');
        controller.IsSuccessDeployment = true;
        controller.redirectToLog();
        Test.stopTest();
    }
    
    static testMethod void testRepositoryContent()
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
        FL_RemoteRepositoryController controller = new FL_RemoteRepositoryController();
        //FL_RemoteRepositoryController.getAttachmentContent(new List<String> {'01I5B0000004KCd'},'"01I5B0000004KCd":"UEsDBAoAAAAIADJh/UiZPrarNAMAAHwRAAAbAAAAb2JqZWN0cy9PYmplY3QxMDBfX2Mub2JqZWN03VjfUxoxEH73r2B46Fs96Gin057nUJTaGcUZobZ9ckJukdRccuYHlf++CbnjkgOtIr2H8iL58mU3+2V3E4yPHzLamoOQhLOjdne/024Bwzwl7Pao/W08ePuhfZzsxX0tFc8uJ78Aq5ZZwuRRe6ZU/jGKJEf5vpxygWEf8yx61+m8jzoHUQYKpUihdrLXMp8YYWV8XBpfgqQgHerNDFEGSQ9jyFUceVDFU4sckhOYIk0NZTlypqONtp/nsY8YBnqakma9Us6gSYcnQEE16rFpSQecUv67SY/nRDYa4RAaDW+E5tD0IY7RpEl312R3ktrs+8r6M6QUiC+C61wmU0SlLbpNc26Z6Zi5MXiOFlyrnpTklmXAVDL6ORqfXsTRY/NudQo55QsLjBRSWpoNWwDSOFqbciuAoQmFnglhThQxu1dCmx2uwT77s6Z3vZwE1BLzeQOAdBWzD/mkM1M0XCwCYyXm864g50KF+ysxnzcCJPAs9FpgAW2GhLnTAnMlFvCUAJQZtB5wMOFWTAnQ1M+sqabUXWPDbqdzc4PjaAVVLHgwScAQ/Zqudl0hFY2iCVBnKY7cwMtOgfBdKVthJcBq1LEAZu/0gLsCa1nf04oPdTYBESa+H+8Twfe1MIbxovuYAKZosCC5raKKbDO2gl+sFmGUMDgDmo/NvG+2NlMX2GPWRc4FYGIfRslhHFWDiiDgXhMBq52txhVFYkQhMSfovjR0gmVQW53fCVLwnKOzvFeemlPcGaqr/wxx/6mGbldb6PfDVGx/8ET2L++Ua0Q1FB0mgDaL7WzutkhKm3+pkJLWaA/qzwDfTfjDdidwqGY76b6uCx7+T61hvbEv5zQj9yb5CgvF6GWqQ4YIPdiJ7s7UEz3B1U3TLeHUbmt76Vw07kd0/VaPmZFrYNlrYhQLWlbQ11Wh3bct8bCoap7jnGqB6Hnhu9yrjzqeXL6y3MtURiXo3lQXPDW8K0Dpd0FsHw1wR50jSlJkO9mVprD5HdWVqqIJQ9uYW/ZFPi+baTHwMk8ILvrcnKg1MuAi0xQFr5TWm1v1qbUMczO5ZuwCpES3kGTub7GqRAtZ18KLI/+/KMneH1BLAQIUAAoAAAAIADJh/UiZPrarNAMAAHwRAAAbAAAAAAAAAAAAAAAAAAAAAABvYmplY3RzL09iamVjdDEwMF9fYy5vYmplY3RQSwUGAAAAAAEAAQBJAAAAbQMAAAAA"');
        Test.stopTest();
    }

    static testMethod void testUpdateVersionComponent()
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

        Component__c comp1 = new Component__c();
        comp1.Component_Name__c = 'page_99';
        comp1.Component_Type__c = 'ApexPage';
        insert comp1;

        String jsonString = '['+
            '{"changedBy":"test user",'+
            '"changedOn":"2016-07-28 11:14:42 GMT",'+
            '"committedBy":"Main Flosum",'+
            '"committedOn":"2016-07-28 12:09:01 GMT",'+
            '"compCRC":"-2018352022 -260042129",'+
            '"compId":"a0D2C000000L52RUAS",'+
            '"compName":"page_99",'+
            '"compType":"ApexPage",'+
            '"contentId":"00P2C000000UWeXUAW",'+
            '"contentSize":578,'+
            '"fileName":"pages/page_99.page",'+
            '"version":1,'+
            '"fullName":"page_99",'+
            '"type":"ApexPage"},'+
            '{"changedBy":"test user",'+
            '"changedOn":"2016-07-28 12:06:44 GMT",'+
            '"committedBy":"Main Flosum",'+
            '"committedOn":"2016-07-28 12:09:02 GMT",'+
            '"compCRC":"455427761 1987776519",'+
            '"compId":"a0D2C000000L52WUAS",'+
            '"compName":"Page7",'+
            '"compType":"ApexPage",'+
            '"contentId":"00P2C000000UWecUAG",'+
            '"contentSize":568,'+
            '"fileName":"pages/Page7.page",'+
            '"version":1,'+
            '"fullName":"Page7",'+
            '"type":"ApexPage"},'+
            '{"changedBy":"test user",'+
            '"changedOn":"2016-07-29 03:19:30 GMT",'+
            '"committedBy":"Main Flosum",'+
            '"committedOn":"2016-07-29 03:24:02 GMT",'+
            '"compCRC":"-1941417868",'+
            '"compId":"a0D2C000000L52rUAC",'+
            '"compName":"Object100__c.X100CF1__c",'+
            '"compType":"CustomField",'+
            '"contentId":"00P2C000000UWh8UAG",'+
            '"contentSize":392,'+
            '"fileName":"objects/Object100__c.object",'+
            '"version":1,'+
            '"fullName":"Object100__c.X100CF1__c",'+
            '"type":"CustomField"}]';

        Test.startTest();
        FL_RemoteRepositoryController controller = new FL_RemoteRepositoryController();
        FL_RemoteRepositoryController.updateVersionComponent(jsonString);
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

        Component__c comp1 = new Component__c();
        comp1.Component_Name__c = 'Object100__c-Object100 Layout';
        comp1.Component_Type__c = 'Layout';
        insert comp1;
        Component__c comp2 = new Component__c();
        comp2.Component_Name__c = 'Object100__c';
        comp2.Component_Type__c = 'CustomObject';
        insert comp2;

        String jsonString = '[{'+
            '"changedBy":"Ravi(DemoOne) Saini",'+
            '"changedOn":"2016-07-29 03:28:13 GMT",'+
            '"committedBy":"Main Flosum",'+
            '"committedOn":"2016-07-29 03:31:13 GMT",'+
            '"compCRC":"-395665602",'+
            '"compId":"a0D2C000000L53aUAC",'+
            '"compName":"Object100__c-Object100 Layout",'+
            '"compType":"Layout",'+
            '"contentId":"00P2C000000UWhwUAG",'+
            '"contentSize":790,'+
            '"fileName":"layouts/Object100__c-Object100 Layout.layout",'+
            '"version":1,'+
            '"fullName":"Object100__c-Object100 Layout",'+
            '"type":"Layout",'+
            '"$$hashKey":"object:28",'+
            '"Status":"Modified",'+
            '"base64Content":"UEsDBAoAAAAIAD1h/UgcJ5q4cgIAAMoMAAAsAAAAbGF5b3V0cy9PYmplY3QxMDBfX2MtT2JqZWN0MTAwIExheW91dC5sYXlvdXTdVm1v2jAQ/s6vQHxfDFM1TVOgCiGIbGlBednLJ2SSA6w6NosdaP79TFKWQKClGkzdkJDC3XN3jx/fXdBvH2PaXEMiCGfdVkdrt5rAQh4Rtui2An/47mPrttfQHZzxVDYVmIluaynl6hNCguOVJuY8CUELeYzet9sfUPsGxSBxhCVu9RpN9dFpHuxBKFURURhzR5gKyWMHz4D25pgK0FHVVAIjlZHQEeAtrx1031iCISJyZ5VJqpBVS4mjeRGbqQPEeEtNR/SgbsHc5DSNq8QrPltCfODJvTNY4jXhSc+FnylJINLRb1MdPSdAox7E6jw302moo8KwXxCdrHgFLvc4hmvRsNR1nEHhe6fdNoedK+pxJhEzTRI1FNkboDLAEl7JYmeudfEluvtM2uMNg8SOLkNbyIxCz9/wJ5fPVz7vc6n2ho4KZ6OaYX/xvO1t5GVCydC8/lLCEWc0O6f5E1A9F/WzS13f36XvYCHv1OtM/brgGf7XFqycFv2Ro9DALLgT9iDOkSUmjBR/NCqZ8usStXfjLgYdBukJ0G3DOkRIUc/jG94XzQv6ny3T309VQ30bjaf3xp11GmaYvv3V9n9oW/wL2QaBNR0Y/jPZCmq+4QfeC6CJa49dVfc0zBy7lhZ4lutpw8BxTp2jopUaqvzZUFeyJjLb2nRUBTwJXtf335X8TJmqSR3D86fB5ETeI4KO1DNPXqWnWPKNtW14cwnhw4w/7ia87igDRmSxpOorxQSzcn8cc5VBNpOQ4HwKHb6oBR5zl8FuygwhyILFwKSbUhDH+D6DKlN56Swm0mCRISUOl/1UrVJWzXIc0NDRbvZ/AVBLAQIUAAoAAAAIAD1h/UgcJ5q4cgIAAMoMAAAsAAAAAAAAAAAAAAAAAAAAAABsYXlvdXRzL09iamVjdDEwMF9fYy1PYmplY3QxMDAgTGF5b3V0LmxheW91dFBLBQYAAAAAAQABAFoAAAC8AgAAAAA="},'+
            '{"changedBy":"Ravi(DemoOne) Saini",'+
            '"changedOn":"2016-07-29 03:19:06 GMT",'+
            '"committedBy":"Main Flosum",'+
            '"committedOn":"2016-07-29 03:41:52 GMT",'+
            '"compCRC":"186042052",'+
            '"compId":"a0D2C000000L52wUAC",'+
            '"compName":"Object100__c",'+
            '"compType":"CustomObject",'+
            '"contentId":"00P2C000000UWi6UAG",'+
            '"contentSize":935,'+
            '"fileName":"objects/Object100__c.object",'+
            '"version":3,'+
            '"fullName":"Object100__c",'+
            '"type":"CustomObject",'+
            '"$$hashKey":"object:32",'+
            '"Status":"Modified",'+
            '"base64Content":"UEsDBAoAAAAIADJh/UiZPrarNAMAAHwRAAAbAAAAb2JqZWN0cy9PYmplY3QxMDBfX2Mub2JqZWN03VjfUxoxEH73r2B46Fs96Gin057nUJTaGcUZobZ9ckJukdRccuYHlf++CbnjkgOtIr2H8iL58mU3+2V3E4yPHzLamoOQhLOjdne/024Bwzwl7Pao/W08ePuhfZzsxX0tFc8uJ78Aq5ZZwuRRe6ZU/jGKJEf5vpxygWEf8yx61+m8jzoHUQYKpUihdrLXMp8YYWV8XBpfgqQgHerNDFEGSQ9jyFUceVDFU4sckhOYIk0NZTlypqONtp/nsY8YBnqakma9Us6gSYcnQEE16rFpSQecUv67SY/nRDYa4RAaDW+E5tD0IY7RpEl312R3ktrs+8r6M6QUiC+C61wmU0SlLbpNc26Z6Zi5MXiOFlyrnpTklmXAVDL6ORqfXsTRY/NudQo55QsLjBRSWpoNWwDSOFqbciuAoQmFnglhThQxu1dCmx2uwT77s6Z3vZwE1BLzeQOAdBWzD/mkM1M0XCwCYyXm864g50KF+ysxnzcCJPAs9FpgAW2GhLnTAnMlFvCUAJQZtB5wMOFWTAnQ1M+sqabUXWPDbqdzc4PjaAVVLHgwScAQ/Zqudl0hFY2iCVBnKY7cwMtOgfBdKVthJcBq1LEAZu/0gLsCa1nf04oPdTYBESa+H+8Twfe1MIbxovuYAKZosCC5raKKbDO2gl+sFmGUMDgDmo/NvG+2NlMX2GPWRc4FYGIfRslhHFWDiiDgXhMBq52txhVFYkQhMSfovjR0gmVQW53fCVLwnKOzvFeemlPcGaqr/wxx/6mGbldb6PfDVGx/8ET2L++Ua0Q1FB0mgDaL7WzutkhKm3+pkJLWaA/qzwDfTfjDdidwqGY76b6uCx7+T61hvbEv5zQj9yb5CgvF6GWqQ4YIPdiJ7s7UEz3B1U3TLeHUbmt76Vw07kd0/VaPmZFrYNlrYhQLWlbQ11Wh3bct8bCoap7jnGqB6Hnhu9yrjzqeXL6y3MtURiXo3lQXPDW8K0Dpd0FsHw1wR50jSlJkO9mVprD5HdWVqqIJQ9uYW/ZFPi+baTHwMk8ILvrcnKg1MuAi0xQFr5TWm1v1qbUMczO5ZuwCpES3kGTub7GqRAtZ18KLI/+/KMneH1BLAQIUAAoAAAAIADJh/UiZPrarNAMAAHwRAAAbAAAAAAAAAAAAAAAAAAAAAABvYmplY3RzL09iamVjdDEwMF9fYy5vYmplY3RQSwUGAAAAAAEAAQBJAAAAbQMAAAAA"}]';

        Test.startTest();
        FL_RemoteRepositoryController controller = new FL_RemoteRepositoryController();
        FL_RemoteRepositoryController.FirstStepMerge(jsonString);
        Test.stopTest();
    }

    static testMethod void testLastAndDeployAtachment()
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
        FL_RemoteRepositoryController controller = new FL_RemoteRepositoryController();
        FL_RemoteRepositoryController.getLastAndDeployAtachment('00P2C000000UWi6UAG','a0D2C000000L52wUAC');
        Test.stopTest();
    }

    static testMethod void testComponentHistoryRemoteBranch()
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
        Set<Id> testSet = new Set<Id>();

        Test.startTest();
        FL_RemoteRepositoryController controller = new FL_RemoteRepositoryController();
        FL_RemoteRepositoryController.getComponentHistoryRemoteBranch(testSet);
        Test.stopTest();
    }
    
}