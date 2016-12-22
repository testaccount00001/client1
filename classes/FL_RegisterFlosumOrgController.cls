public with sharing class FL_RegisterFlosumOrgController 
{
    public FL_Credentials__c creds{get; set;}
    public FL_Flosum_Org__c credUpdate;
    public FL_Deployment_Settings__c deploySettings{get; set;}
    public boolean isAuthSuccessful {get; private set;}
    
    public String loginUrl{get; set;}
    private String className = 'FL_RegisterFlosumOrgController';
    
    public List<SelectOption> hostOptions{get; set;}
    
    public List<SelectOption> branchOptions{get; set;}
    public String selectedBranch{get; set;}
    public String branchName{get; set;}
    
    public String hostUrl{get; set;}
    public String selectedhostType{get; set;}
    public String userName{get; set;}
    public String password{get; set;}
    
    public String GOVT_ORG_PICK_VAL =   'Government cloud org';
    public String SANDBOX_PICK_VAL =    'Sandbox';
    public String PRODUCTION_PICK_VAL = 'Developer/Production';
    
    public String remoteSiteSettingURL {get;set;}
    public String PlaceOfException{get;set;}
    
    private String instanceType;
    private String InstanceUrl;
    private String RefereshToken;
    private String AccessToken;
    private String sfid;
    
    public FL_RegisterFlosumOrgController()
    {
        branchOptions = new List<SelectOption>();
        credUpdate = FL_Flosum_Org__c.getOrgDefaults();
        deploySettings = FL_Deployment_Settings__c.getOrgDefaults();
        creds = (FL_Credentials__c.getOrgDefaults() != null && FL_Credentials__c.getOrgDefaults().id != null) ? FL_Credentials__c.getOrgDefaults() : new FL_Credentials__c();
        hostOptions = new List<SelectOption>();
        hostOptions.add(new SelectOption('Developer/Production', 'Developer/Production'));
        hostOptions.add(new SelectOption('Sandbox', 'Sandbox'));
        hostOptions.add(new SelectOption('Government cloud org', 'Government cloud org'));
        //
        if(creds!= null && creds.Id != null)
        {}
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Fill OAuth Authentication Details.'));
        }
    }
    
    public void checkAuthentication()
    {
        isAuthSuccessful = false;
        if(credUpdate != null && credUpdate.Id != null && creds != null && creds.Id != null)
        {
            try
            {
                String endpoint = credUpdate.Instance_URL__c+'/services/oauth2/token?grant_type=refresh_token'+
                      '&refresh_token='+credUpdate.Refresh_Token__c+
                      '&client_id='+creds.ConsumerKey__c+
                      '&client_secret='+creds.ConsumerSecret__c;
    
                HttpRequest req = new HttpRequest();
                req.setEndpoint(endpoint);
                req.setMethod('POST');
                req.setTimeout(120000);
                Http h = new Http();
                String resp;
                HttpResponse res;
                res= h.send(req);
                resp = res.getBody();
                Map<String,Object> params = (Map<String,Object>)JSON.deserializeUntyped(resp);
                if(res.getStatusCode() == 200)
                {
                    if(params.containsKey('access_token'))
                    {
                        String accessToken = (String) params.get('access_token');
                        String refreshToken = (String) params.get('refresh_token');
                        if(refreshToken != null)
                            credUpdate.Refresh_Token__c = refreshToken;
                        if(accessToken != null)
                        {
                            userName = credUpdate.User_Name__c;
                            selectedhostType = credUpdate.Org_Type__c;
                            hostUrl = credUpdate.Instance_URL__c;
                            credUpdate.Access_Token__c = accessToken;
                            listFlosumBranches();
                            update credUpdate;
                            isAuthSuccessful = true;
                        }
                    }
                    else
                    {
                        String error = (String)params.get('error_description');
                        if(error != null)
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));
                        else
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Authentication Failed.'));
                    }
                }
                else
                {
                    String error = (String)params.get('error_description');
                    if(error != null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,error));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Authentication Failed.'));
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
        }
    }
    
    public void listFlosumBranches()
    {
        branchOptions.clear();
        branchOptions.add(new SelectOption('', '-- New Branch --'));
        selectedBranch = null;
        if(credUpdate.Id != null)
        {
            try
            {
                FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(credUpdate.Access_Token__c,credUpdate.Instance_URL__c);
                String response = service.listBranches();
                List<BranchInfoWraper> branchLi = (List<BranchInfoWraper>) JSON.deserialize(response, List<BranchInfoWraper>.class);
                for(BranchInfoWraper wrap : branchLi)
                {
                    if(credUpdate.BranchToCommit__c == wrap.branchId)
                    {
                        selectedBranch = credUpdate.BranchToCommit__c;
                    }
                    branchOptions.add(new SelectOption(wrap.branchId, wrap.branchName));
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
        }
    }
    
    public PageReference saveDeploymentSettings()
    {
        upsert deploySettings;
        PageReference pref = Page.FL_RegisterFlosumOrg;
        pref.setRedirect(true);
        return pref;
    }
    
    public PageReference saveBranch()
    {
        if(credUpdate.Id != null)
        {
            if(selectedBranch != null && selectedBranch != '')
            {
                credUpdate.BranchToCommit__c = selectedBranch;
                update credUpdate;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Saved Successfully.'));
                PageReference pref = Page.FL_RegisterFlosumOrg;
                pref.setRedirect(true);
                return pref;
            }
            else if(branchName != null && branchName.trim() != '')
            {
                if(branchName.length() <= 255)
                {
                    try
                    {
                        BranchNameWraper wrap = new BranchNameWraper();
                        wrap.branchName = branchName;
                        //wrap.branchDescription='';
                        FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(credUpdate.Access_Token__c,credUpdate.Instance_URL__c);
                        String response = service.createBranch(JSON.serialize(wrap));
                        BranchInfoWraper branchInfo = new BranchInfoWraper();
                        branchInfo = (BranchInfoWraper)JSON.deserialize(response, BranchInfoWraper.class);
                        credUpdate.BranchToCommit__c = branchInfo.branchId;
                        update credUpdate;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Saved Successfully.'));
                        PageReference pref = Page.FL_RegisterFlosumOrg;
                        pref.setRedirect(true);
                        return pref;
                    }
                    catch(Exception ex)
                    {
                        if(ex.getMessage().containsIgnoreCase('Branch already exist with same Name'))
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Branch already exist in Flosum org with same name.'));
                        else
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
                    }
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Branch name too large, branch name should not contain more than 255 characters.'));
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter branch name.'));
            }
        }
        return null;
    }
    
    public PageReference save()
    {
        if(creds.ConsumerKey__c == null || creds.ConsumerKey__c == '' || creds.ConsumerSecret__c == null || creds.ConsumerSecret__c == '')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please Fill All Mandatory Fields.'));
        }
        else
        {
            String NameSpacePrefix = FL_RegisterFlosumOrgController.class.getName().substringBefore('FL_RegisterFlosumOrgController');
            if(NameSpacePrefix != '')
            {
                NameSpacePrefix = NameSpacePrefix.replace('.','');
            }
            FL_Credentials__c tempCred = FL_Credentials__c.getOrgDefaults();
            if(tempCred != null && tempCred.Id != null)
            {
                tempCred.ConsumerKey__c = creds.ConsumerKey__c;
                tempCred.ConsumerSecret__c = creds.ConsumerSecret__c;
                tempCred.Namespace__c = NameSpacePrefix;
                tempCred.Redirect_URL__c = 'oob';
                update tempCred;
                PageReference pref = Page.FL_RegisterFlosumOrg;
                pref.setRedirect(true);
                return pref;
            }
            else
            {
                tempCred = new FL_Credentials__c();
                tempCred.ConsumerKey__c = creds.ConsumerKey__c;
                tempCred.ConsumerSecret__c = creds.ConsumerSecret__c;
                tempCred.Namespace__c = NameSpacePrefix;
                tempCred.Redirect_URL__c = 'oob';
                insert tempCred;
                PageReference pref = Page.FL_RegisterFlosumOrg;
                pref.setRedirect(true);
                return pref;
            }
        }
        return null;
    }
    
    public PageReference cancel()
    {
        return new Pagereference('/home/home.jsp');
    }
    
    public void processLogin()
    {
        loginUrl = '';
        if(selectedhostType == GOVT_ORG_PICK_VAL)
        {
            instanceType = hostUrl;
        }
        else if(selectedhostType == SANDBOX_PICK_VAL)
        {
            instanceType = 'https://test.salesforce.com';
        }
        else
        {
            instanceType = 'https://login.salesforce.com';
        }
        if(instanceType != null)
        {
            instanceType = instanceType.toLowerCase();
            loginUrl = instanceType+'/services/oauth2/authorize?response_type=code'+
                      '&client_id='+EncodingUtil.urlEncode(creds.ConsumerKey__c,'UTF-8')+
                      '&redirect_uri='+EncodingUtil.urlEncode(creds.redirect_url__c,'UTF-8')+'&state=mystate';
        }
    }
    
    public Pagereference checkAndSave()
    {           
        PlaceOfException = '';
        remoteSiteSettingURL = '';
        if(selectedhostType != GOVT_ORG_PICK_VAL || (hostUrl != null && hostUrl != ''))
        {
            if(selectedhostType == GOVT_ORG_PICK_VAL)
            {
                instanceType = hostUrl;
            }
            else if(selectedhostType == SANDBOX_PICK_VAL)
            {
                instanceType = 'https://test.salesforce.com';
            }
            else
            {
                instanceType = 'https://login.salesforce.com';
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Enter a Valid Hostname.'));
            return null;
        }
        //this.instanceType = this.organizationRecord.Organisation_Type__c == 'Sandbox' ? 'https://test.salesforce.com' : 'https://login.salesforce.com';
        if((userName == null || userName =='') || (password ==null || password =='') || (selectedhostType ==null))
        {
            if(userName ==null || userName =='')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Enter Valid Username.'));
            }
            if(password ==null || password =='')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Enter Valid Authorization Code.'));
            }
            if(selectedhostType ==null)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Enter Valid Organization Type.'));
            }
        }
        else
        {
            try
            {
                this.instanceType = this.instanceType.toLowerCase();
                String endpoint = this.instanceType+'/services/oauth2/token?grant_type=authorization_code'+
                        '&redirect_uri='+EncodingUtil.urlEncode(creds.redirect_url__c,'UTF-8')+
                        '&code='+EncodingUtil.urlEncode(password,'UTF-8')+
                        '&client_id='+creds.ConsumerKey__c+
                        '&client_secret='+creds.ConsumerSecret__c;
                        
                HttpResponse res =  sendRequest(endpoint);
                if(res != null)
                {
                    
                    String response = res.getBody();
                    if(res.getStatusCode() == 200)
                    {
                        InstanceUrl = getValue(response,'instance_url');
                        InstanceUrl = InstanceUrl != null ? InstanceUrl.toLowerCase() : InstanceUrl;
                        RefereshToken = getValue(response,'refresh_token');
                        AccessToken = getValue(response,'access_token');
                        sfid = getValue(response,'id');
                        System.debug(sfid);
                        PageReference pref = getOrgDetail(InstanceUrl, RefereshToken,AccessToken, sfid);
                        if(pref != null)
                            return pref;
                    }
                    else
                    {
                        String error = getValue(response,'error_description');
                        if(error != null)
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,convertMessage(error)));
                        else
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Authentication Failed.'));
                    }
                }
            }
            catch(Exception ex)
            {
                String exMessage = ex.getMessage();
                if(exMessage.contains('Unauthorized endpoint, please check Setup->Security->Remote site settings. endpoint = '))
                {
                    if(exMessage.contains('/services/oauth2/token?grant_type=authorization_code'))
                    {
                        PlaceOfException = 'AUTHORIZATION';
                        remoteSiteSettingURL = exMessage.substring(86,exMessage.indexOf('/services/oauth2/token?grant_type=authorization_code'));
                        return null;
                    }
                    else if(ex.getMessage().contains('/id/'))
                    {
                        PlaceOfException = 'ID';
                        remoteSiteSettingURL = exMessage.substring(86,exMessage.indexOf('/id/'));
                        return null;
                    }
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage())); 
            }
        }   
        return null;
    }
    
    public PageReference completeRegisterOrg()
    {
        try
        {
            PageReference pref = getOrgDetail(this.InstanceUrl, this.RefereshToken,this.AccessToken, this.sfid);
            if(pref != null)
                return pref;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return null;
    }
    
    public PageReference getOrgDetail(String IUrl, String RToken, String AToken, String sfd)
    {
        if(IUrl != '' && RToken != '' && AToken != '' && sfd != '')
        {
            HttpResponse res = sendRequestWithToken(sfd.replace(this.instanceType, IUrl),AToken);
            if(res != null)
            {
                String response;
                if(res.getStatusCode() == 200)
                {
                    response = res.getBody();
                    String OrgUserName = getValue(response,'username');
                    String UserFullName = getValue(response,'display_name');
                    String OrganisationId = getValue(response,'organization_id');
                    if(userName == OrgUserName)
                    {
                        FL_Flosum_Org__c credUpdate = FL_Flosum_Org__c.getOrgDefaults();
                        if(credUpdate!= null && credUpdate.Id != null)
                        {
                            credUpdate.Access_Token__c= AToken;
                            credUpdate.Instance_URL__c= IUrl;
                            credUpdate.Org_Id__c= OrganisationId;
                            credUpdate.Refresh_Token__c= RToken;
                            credUpdate.User_Name__c= OrgUserName;
                            credUpdate.Org_Type__c = selectedhostType;
                            //credUpdate.BranchToCommit__c = null;
                            update credUpdate;
                        }
                        else
                        {
                            credUpdate.Access_Token__c= AToken;
                            credUpdate.Instance_URL__c= IUrl;
                            credUpdate.Org_Id__c= OrganisationId;
                            credUpdate.Refresh_Token__c= RToken;
                            credUpdate.User_Name__c= OrgUserName;
                            credUpdate.Org_Type__c = selectedhostType;
                            //credUpdate.BranchToCommit__c = null;
                            insert credUpdate;
                        }
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Saved Successfully.'));
                        PageReference pref = Page.FL_RegisterFlosumOrg;
                        pref.setRedirect(true);
                        return pref;
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Username ('+userName+') does not match with username ('+OrgUserName+').'));
                    }
                }
                else
                {
                    String error = getValue(response,'error_description');
                    if(error != null)
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,convertMessage(error)));
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Authentication Failed.'));
                }
            }
        }
        return null;
    }
    
    private HttpResponse sendRequest(String endpoint)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        return res;
    }
    
    private HttpResponse sendRequestWithToken(String endpoint, String token)
    {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setHeader('Authorization', 'Bearer '+token);
        req.setMethod('GET');
        Http h = new Http();
        String resp;
        HttpResponse res = h.send(req);
        return res;
    }
    
    public String convertMessage(String message)
    {
        if(message != null)
        {
            List<String> elems = message.split(' ');
            message = '';
            for (String x : elems)
            {
                message += x.substring(0,1).toUpperCase()+x.substring(1,x.length()) + ' ';
            }
        }
        return message;
    }
    
    private String getValue(String response, String key)
    {
        Map<String,Object> params = (Map<String,Object>)JSON.deserializeUntyped(response);
        return (String)params.get(key);
    }
    
    public class BranchNameWraper
    {
        public String branchName;
        public String branchDescription;
    }
    
    public class BranchInfoWraper
    {
        public String branchId;
        public String branchName;
        public String branchNumber;
    }
}