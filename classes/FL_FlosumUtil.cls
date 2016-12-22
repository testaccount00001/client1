public with sharing class FL_FlosumUtil 
{
	public static FL_FlosumService.FlosumExtService createService(String session,String instance)
	{
		FL_FlosumService.FlosumExtService service = new FL_FlosumService.FlosumExtService();
    	service.setEndpointX(instance);
    	service.SessionHeader = new FL_FlosumService.SessionHeader_element();
    	service.SessionHeader.sessionId = session;
    	service.timeout_x = 120000;
    	return service;
	}
	
	public class WebServiceMockImpl implements WebServiceMock 
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) 
		{
			if(request instanceof FL_FlosumService.getSupportedMetadataTypes_element)
			{
				FL_FlosumService.getSupportedMetadataTypesResponse_element res = new FL_FlosumService.getSupportedMetadataTypesResponse_element();
				res.result = new List<String>{'ApexClass'};
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.getBaseAPIVersion_element)
			{
				FL_FlosumService.getBaseAPIVersionResponse_element res = new FL_FlosumService.getBaseAPIVersionResponse_element();
				res.result = 36;
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.commitToBranch_element)
			{
				FL_FlosumService.commitToBranchResponse_element res = new FL_FlosumService.commitToBranchResponse_element();
				res.result = '';
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.checkCrcFromBranchAndRemoteRepository_element)
			{
				FL_FlosumService.checkCrcFromBranchAndRemoteRepositoryResponse_element res = new FL_FlosumService.checkCrcFromBranchAndRemoteRepositoryResponse_element();
				res.result = JSON.serialize(new FL_LocalWorkspaceController.CRCResultWraper());
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.checkComponentsWithBranch_element)
			{
				FL_FlosumService.checkComponentsWithBranchResponse_element res = new FL_FlosumService.checkComponentsWithBranchResponse_element();
				
				FL_RemoteRepositoryController.RepositoryComponentsBranchWrapper testComp1 = new FL_RemoteRepositoryController.RepositoryComponentsBranchWrapper();
				testComp1.compId = 'a0D2C000000L53aUAC';
				testComp1.compName = 'Object100__c-Object100 Layout';
				testComp1.compType = 'Layout';
				testComp1.reason = 'Same as Version 1.00 in Repository';
				testComp1.version  = 1;
				testComp1.compCRC = '-395665602';
				testComp1.changedBy = 'Test user';
				testComp1.changedOn = '2016-07-29 03:28:13 GMT';
				testComp1.committedBy = 'Main Flosum';
				testComp1.committedOn = '2016-07-29 03:31:13 GMT';
				testComp1.fileName = 'layouts/Object100__c-Object100 Layout.layout';
				testComp1.contentId = '00P2C000000UWhwUAG';
				testComp1.contentSize = 790;
				FL_RemoteRepositoryController.RepositoryComponentsBranchWrapper testComp2 = new FL_RemoteRepositoryController.RepositoryComponentsBranchWrapper();
				testComp2.compId = 'a0D2C000000L52wUAC';
				testComp2.compName = 'Object100__c';
				testComp2.compType = 'CustomObject';
				testComp2.reason = 'Same as Version 2.00 in Repository';
				testComp2.version  = 3;
				testComp2.compCRC = '186042052';
				testComp2.changedBy = 'Test user';
				testComp2.changedOn = '2016-07-29 03:19:06 GMT';
				testComp2.committedBy = 'Main Flosum';
				testComp2.committedOn = '2016-07-29 03:41:52 GMT';
				testComp2.fileName = 'objects/Object100__c.object';
				testComp2.contentId = '00P2C000000UWi6UAG';
				testComp2.contentSize = 935;

				res.result = JSON.serialize(new List<FL_RemoteRepositoryController.RepositoryComponentsBranchWrapper>{testComp1,testComp2});
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.checkAttachmentsWithBranch_element)
			{
				FL_FlosumService.checkAttachmentsWithBranchResponse_element res = new FL_FlosumService.checkAttachmentsWithBranchResponse_element();
				res.result = JSON.serialize(new List<FL_RemoteRepositoryController.RepositoryAttachmentsBranchWrapper>());
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.checkAttachmentsWithBranchID_element)
			{
				FL_FlosumService.checkAttachmentsWithBranchIDResponse_element res = new FL_FlosumService.checkAttachmentsWithBranchIDResponse_element();

    			FL_RemoteRepositoryController.RepositoryAttachmentsBranchWrapper att1 = new FL_RemoteRepositoryController.RepositoryAttachmentsBranchWrapper();
    			att1.Id = '00P2C000000UWi6UAG';
    			att1.parentId = 'a0D2C000000L53aUAC';
    			att1.compType = 'CustomObject';
    			FL_RemoteRepositoryController.RepositoryAttachmentsBranchWrapper att2 = new FL_RemoteRepositoryController.RepositoryAttachmentsBranchWrapper();
    			att2.Id = '00P2C000000UWhwUAG';
    			att2.parentId = 'a0D2C000000L53aUAC';
    			att2.compType = 'Layout';

				res.result = JSON.serialize(new List<FL_RemoteRepositoryController.RepositoryAttachmentsBranchWrapper>{att1,att2});
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.checkPatchRemoteBranch_element)
			{
				FL_FlosumService.checkPatchRemoteBranchResponse_element res = new FL_FlosumService.checkPatchRemoteBranchResponse_element();
				res.result = JSON.serialize(new List<FL_LocalWorkspaceController.PatchManifestWrapper>());
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.checkComponentHistoryRemoteBranch_element)
			{
				FL_FlosumService.checkComponentHistoryRemoteBranchResponse_element res = new FL_FlosumService.checkComponentHistoryRemoteBranchResponse_element();

    			FL_RemoteRepositoryController.ComponentHistoryWrapper his1 = new FL_RemoteRepositoryController.ComponentHistoryWrapper();
    			his1.Id = '11P2C000000UWi6UAG';
    			his1.component = 'a0D2C000000L53aUAC';
    			his1.version = 1;
    			his1.CRC32 = '186042053';
    			his1.compName = 'Object100__c';
    			his1.compType = 'CustomObject';
    			FL_RemoteRepositoryController.ComponentHistoryWrapper his2 = new FL_RemoteRepositoryController.ComponentHistoryWrapper();
    			his2.Id = '11P2C000000UWhwUAG';
    			his2.component = 'a0D2C000000L53aUAC';
    			his2.version = 1;
    			his2.CRC32 = '186042054';
    			his2.compName = 'Object100__c-Object100 Layout';
    			his2.compType = 'Layout';
    			FL_RemoteRepositoryController.ComponentHistoryWrapper his3 = new FL_RemoteRepositoryController.ComponentHistoryWrapper();
    			his3.Id = '11P2C000000UWhwUAG';
    			his3.component = 'a0D2C000000L53aUAC';
    			his3.version = 2;
    			his3.CRC32 = '186042055';
    			his3.compName = 'Object100__c-Object100 Layout';
    			his3.compType = 'Layout';
    			FL_RemoteRepositoryController.ComponentHistoryWrapper his4 = new FL_RemoteRepositoryController.ComponentHistoryWrapper();
    			his4.Id = '11P2C000000UWhwUAG';
    			his4.component = 'a0D2C000000L53aUAC';
    			his4.version = 3;
    			his4.CRC32 = '186042056';
    			his4.compName = 'Object100__c-Object100 Layout';
    			his4.compType = 'Layout';


				res.result = JSON.serialize(new List<FL_RemoteRepositoryController.ComponentHistoryWrapper>{his1,his2,his3,his4});
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.getRepoComponents_element)
			{
				FL_FlosumService.getRepoComponentsResponse_element res = new FL_FlosumService.getRepoComponentsResponse_element();
				res.result = JSON.serialize(new List<FL_RemoteRepositoryController.RepositoryComponentWrapper>());
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.getContentOfComponents_element)
			{
				FL_FlosumService.getContentOfComponentsResponse_element res = new FL_FlosumService.getContentOfComponentsResponse_element();
				res.result = JSON.serialize(new List<FL_RemoteRepositoryController.ContentWraper>());
				response.put('response_x', res);
			}
			else if(request instanceof FL_FlosumService.listBranches_element)
			{
				FL_FlosumService.listBranchesResponse_element res = new FL_FlosumService.listBranchesResponse_element();
				FL_RegisterFlosumOrgController.BranchInfoWraper branch = new FL_RegisterFlosumOrgController.BranchInfoWraper();
				branch.branchId = '1234';
				branch.branchName = 'Branch';
				res.result = JSON.serialize(new List<FL_RegisterFlosumOrgController.BranchInfoWraper>{branch});
				response.put('response_x', res);
			}
			return;
		}
	}
	
	public class MockHttpResponseGenerator implements HttpCalloutMock 
    {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) 
        {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String endPoint = req.getEndpoint();
            if(endPoint.endsWith('/services/data/v26.0/'))
            {
            	res.setBody('{"Error":"Error","id":"https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P", "issued_at":"1278448101416", "refresh_token":"5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_ pZebnUG0h6Sb4KUVDpNtWEofWM39yg==", "instance_url":"https://na1.salesforce.com", "signature":"CMJ4l+CCaPQiKjoOEwEig9H4wqhpuLSk4J2urAe+fVg=", "access_token":"00Dx0000000BV7z!AR8AQP0jITN80ESEsj5EbaZTFG0R NBaT1cyWk7TrqoDjoNIWQ2ME_sTZzBjfmOE6zMHq6y8PIW4eWze9JksNEkWUl.Cju7m4", "username":"test@testOrg.com"}');
            }
            else
            	res.setBody('{"id":"https://login.salesforce.com/id/00Dx0000000BV7z/005x00000012Q9P", "issued_at":"1278448101416", "refresh_token":"5Aep8614iLM.Dq661ePDmPEgaAW9Oh_L3JKkDpB4xReb54_ pZebnUG0h6Sb4KUVDpNtWEofWM39yg==", "instance_url":"https://na1.salesforce.com", "signature":"CMJ4l+CCaPQiKjoOEwEig9H4wqhpuLSk4J2urAe+fVg=", "access_token":"00Dx0000000BV7z!AR8AQP0jITN80ESEsj5EbaZTFG0R NBaT1cyWk7TrqoDjoNIWQ2ME_sTZzBjfmOE6zMHq6y8PIW4eWze9JksNEkWUl.Cju7m4", "username":"test@testOrg.com"}');
            res.setStatusCode(200);
            return res;
        }
    }

}