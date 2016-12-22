public with sharing class FL_LocalWorkspaceController 
{
    public Integer localApiVersion{get; private set;}
    public FL_Flosum_Org__c credUpdate {get; private set;}
    private FL_Credentials__c credentials;
    public String commitStr{get; set;}
    public String logId{get; private set;}
    public String syncId{get; private set;}
    public String exceptionMessage{get; private set;}
    public String supportedTypes{get; private set;}
    public boolean isAuthSuccessful {get; private set;}
    public String branchName {get; private set;}
    
    public String syncName {get; set;}
    public Integer lastModifiedInDays{get; set;}
    public boolean IsRetrieveStandard{get; set;}
    public Long filterMiliSeconds{get; private set;}
    public boolean isProcessSuccessful {get; private set;}

    public String customLookupPageName {get; private set;}

    public List<SelectOption> leftOptionList{get;set;}
    public List<SelectOption> rightOptionList{get;set;}
    public String localZoneStr{get;set;}

    public String localUser{get;set;}

    //constructor
    public FL_LocalWorkspaceController() 
    {   
        localUser = UserInfo.getName();
        localZoneStr = UserInfo.getTimeZone().getID();
        customLookupPageName = Page.FL_CustomLookup.getUrl();
        leftOptionList = new List<SelectOption>();
        rightOptionList = new List<SelectOption>();
        syncName = System.now().format('YYYY-MM-dd HH:mm')+' Upload';
        localApiVersion = 36;
        lastModifiedInDays = 14;
        supportedTypes = '';
        IsRetrieveStandard = false;
        credUpdate = FL_Flosum_Org__c.getOrgDefaults();
        credentials = FL_Credentials__c.getOrgDefaults();
    }
    
    public void checkAuthentication()
    {
        isAuthSuccessful = false;
        if(credUpdate != null && credUpdate.Id != null && credentials != null && credentials.Id != null)
        {
            try
            {
                if(credUpdate.BranchToCommit__c != null && credUpdate.BranchToCommit__c != '')
                {
                    String endpoint = credUpdate.Instance_URL__c+'/services/oauth2/token?grant_type=refresh_token'+
                          '&refresh_token='+credUpdate.Refresh_Token__c+
                          '&client_id='+credentials.ConsumerKey__c+
                          '&client_secret='+credentials.ConsumerSecret__c;
        
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
                                credUpdate.Access_Token__c = accessToken;
                                listSupportedMetadataTypes();
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
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,FL_LocalFlosumConstants.REGISTER_BRANCH_MESSAGE));
                }
            }
            catch(Exception ex)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,FL_LocalFlosumConstants.REGISTER_FLOSUM_ORG_MESSAGE));
        }
    }
    
    public void listMetadataItems()
    {
        isProcessSuccessful = false;
        filterMiliSeconds = 0;
        if(lastModifiedInDays != null && lastModifiedInDays >= 0)
        {
            if(lastModifiedInDays != 0)
            {
                DateTime tempDt = System.now();
                tempDt = tempDt.addDays(-lastModifiedInDays);
                filterMiliSeconds = tempDt.getTime();
            }
            isProcessSuccessful = true;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Please enter a positive number.'));
        }
    }

    public void listSupportedMetadataTypes()
    {
        if(credUpdate != null && credUpdate.Id != null )
        {
            FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(credUpdate.Access_Token__c,credUpdate.Instance_URL__c);
            List<String> responseTypes =  new List<String>();
            // get supported metadata types from flosum org.
            responseTypes = service.getSupportedMetadataTypes();
            // get api version from Flosum Org
            localApiVersion = service.getBaseAPIVersion();
            branchName = service.getBranchName(credUpdate.BranchToCommit__c);
            supportedTypes = JSON.serialize(responseTypes);
        }
    }
    
    public void createLog()
    {
        exceptionMessage = '';
        logId = '';
        try
        {
            List<FL_Upload_Log__c> oldLogList = new List<FL_Upload_Log__c>();
            oldLogList = [SELECT Id FROM FL_Upload_Log__c WHERE CreatedBy.Id=:UserInfo.getUserId()];
            if(oldLogList.size() > 0 && oldLogList.size() < 1000)
            {
                try
                {
                    delete oldLogList;
                }
                catch(Exception ex)
                {}
            }
            FL_Upload_Log__c log = new FL_Upload_Log__c();
            insert log;
            logId = log.Id;
        }
        catch(Exception ex)
        {
            exceptionMessage = ex.getMessage();
        }
    }
    
    public void createSyncLog()
    {
        exceptionMessage = '';
        syncId = '';
        try
        {
            if(syncName != null && syncName != '')
            {
                FL_Sync__c sync = new FL_Sync__c();
                sync.Sync_Type__c = FL_LocalFlosumConstants.SYNC_TYPE_UPLOAD;
                sync.Name = syncName;
                sync.Branch_Name__c = branchName;
                insert sync;
                syncId = sync.Id;
            }
            else
                exceptionMessage = 'Please enter sync name.';
        }
        catch(Exception ex)
        {
            exceptionMessage = ex.getMessage();
        }
    }
    
    public PageReference finishCommit()
    {
        List<FL_Upload_Log__c> tempLogList = new List<FL_Upload_Log__c>();
        tempLogList = [SELECT Id FROM FL_Upload_Log__c WHERE Id=:logId LIMIT 1];
        if(tempLogList.size() == 1)
        {
            delete tempLogList;
        }
        List<FL_Sync__c> logList = new List<FL_Sync__c>();
        logList = [SELECT Id,Job_Completed__c,Succeed__c FROM FL_Sync__c WHERE Id=:syncId];
        if(logList.size() == 1)
        {
            logList[0].Job_Completed__c = true;
            logList[0].Succeed__c = true;



            System.debug('IIIIIII 1 \n\n');
/////////////////////////////
            //List<FL_Sync_Component__c> compLi = new List<FL_Sync_Component__c>();
            List<String> listName = new List<String>();
            List<FL_Sync_Component__c> syncComponent = [
                    SELECT Id,Component_Type__c,Component_Name__c,File_Name__c,CRC32__c,Changed_On__c,Changed_By__c
                    FROM FL_Sync_Component__c
                    WHERE Sync__c =:logList[0].Id
                ];
            
            System.debug('IIIIIII syncComponent \n\n' + syncComponent);
            for (FL_Sync_Component__c sync : syncComponent) {
                listName.add(sync.Component_Name__c);
                //FL_Sync_Component__c comp = new FL_Sync_Component__c();
                //comp.Component_Type__c = sync.Component_Type__c;
                //comp.Component_Name__c = sync.Component_Name__c;
                //comp.File_Name__c = sync.File_Name__c;
                //comp.CRC32__c = sync.CRC32__c;
                //comp.Changed_On__c = sync.Changed_On__c;
                //comp.Changed_By__c = sync.Changed_By__c;
                //comp.Sync__c = syncLi[0].Id;
                //compLi.add(comp);
            }
            System.debug('IIIIIII listName.size() \n\n' + listName.size());
            if (listName.size() > 0) {
                List<Component__c> listComp = [SELECT Id, Component_Name__c, Component_Type__c FROM Component__c WHERE Component_Name__c IN :listName];
                Map<String, Id> mapComp = new Map<String, Id>();
                for (Component__c comp : listComp) {
                    mapComp.put(comp.Component_Name__c + '#' + comp.Component_Type__c, comp.Id);
                }

                System.debug('IIIIIII listComp \n\n' + listComp);
                List<Component__c> listUpdComp = new List<Component__c>();
                for (FL_Sync_Component__c sync : syncComponent) {
                    Component__c tempComp = new Component__c();
                    System.debug('IIIIIII mapComp.get(sync.Component_Name__c # sync.Component_Type__c) \n\n' + mapComp.get(sync.Component_Name__c + '#' + sync.Component_Type__c));
                    if (mapComp.get(sync.Component_Name__c + '#' + sync.Component_Type__c) == null) {
                        tempComp.Component_Name__c = sync.Component_Name__c;
                        tempComp.Component_Type__c = sync.Component_Type__c;
                        tempComp.Last_Updated_By__c = sync.Changed_By__c;
                        tempComp.Changed_On__c = sync.Changed_On__c!=null ? sync.Changed_On__c : System.now();
                        tempComp.Last_Modified_By__c = sync.Changed_By__c;
                        tempComp.Committed_On__c = sync.Changed_On__c!=null ? sync.Changed_On__c : System.now();
                        tempComp.CRC32__c = sync.CRC32__c;
                        tempComp.File_Name__c = sync.File_Name__c;
                        tempComp.Version__c = 1;

                        System.debug('IIIIIII 1 \n\n');
                        listUpdComp.add(tempComp);
                    }
                }

                if(listUpdComp.size() > 0) {
                    System.debug('listUpdComp 1 \n\n' + listUpdComp);
                    insert listUpdComp;
                }
            }




/////////////////////////////
            update logList;
            return new PageReference('/'+logList[0].Id);
        }
        return null;
    }
    
    public void createTempRecordsForCommit()
    {
        exceptionMessage = '';
        try
        {
            if(commitStr != null && commitStr != '')
            {
                if(logId != null)
                {
                    if(credUpdate != null && credUpdate.Id != null )
                    {
                        CommitWraper wrapInfo = (CommitWraper) JSON.deserialize(commitStr, CommitWraper.class);
                        if(wrapInfo.fullNames != null && wrapInfo.metaTypes != null && wrapInfo.dataMap != null)
                        {
                            List<FL_Upload_Manifest__c> insertList = new List<FL_Upload_Manifest__c>();
                            for(CompDetailWraper wrap : wrapInfo.dataMap.values())
                            {
                                FL_Upload_Manifest__c comp= new FL_Upload_Manifest__c();
                                comp.CRC32__c = wrap.crcCode ;
                                comp.Component_Type__c = wrap.metaType;
                                comp.Component_Name__c = wrap.fullName;
                                comp.Upload_Log__c = logId;
                                comp.Changed_On__c = wrap.lastModifiedDate!=null ? DateTime.valueOfGmt(wrap.lastModifiedDate.replace('T',' ')) : System.now();
                                comp.Changed_By__c = wrap.lastModifiedByName;
                                comp.File_Name__c = wrap.fileName;
                                if(wrap.base64Content != null)
                                {
                                    comp.Commit_Status__c = FL_LocalFlosumConstants.SAFE_TO_COMMIT;
                                }
                                else
                                {
                                    comp.Commit_Status__c = FL_LocalFlosumConstants.NOT_TO_COMMIT;
                                    comp.Reason__c = wrap.reason;
                                }
                                insertList.add(comp);
                            }
                            if(insertList.size() > 0)
                            {
                                insert insertList;
                                List<Attachment> attList = new List<Attachment>();
                                for(FL_Upload_Manifest__c history : insertList)
                                {
                                    if(history.Commit_Status__c == FL_LocalFlosumConstants.SAFE_TO_COMMIT)
                                    {
                                        Attachment att = new Attachment();
                                        att.Name = history.Component_Type__c;
                                        att.ParentId = history.Id;
                                        att.Description = history.Component_Type__c;
                                        att.contentType = 'application/zip';
                                        if(wrapInfo.dataMap.containsKey(history.Component_Type__c+'#'+history.Component_Name__c))
                                        {
                                            att.Body = EncodingUtil.base64Decode(wrapInfo.dataMap.get(history.Component_Type__c+'#'+history.Component_Name__c).base64Content);
                                            wrapInfo.dataMap.remove(history.Component_Type__c+'#'+history.Component_Name__c);
                                            attList.add(att);
                                        }
                                    }
                                }
                                if(attList.size() > 0)
                                {
                                    insert attList;
                                }
                            }
                        }
                    }
                }
                commitStr = null;
            }
        }
        catch(Exception ex)
        {
            logId = null;
            exceptionMessage = ex.getMessage();
        }
    }
    
    @RemoteAction
    public static String commitComponents(List<String> compLogIds,String syncId)
    {
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if(cred != null && cred.BranchToCommit__c != null )
        {
            CommitWraper wrap = new CommitWraper();
            Map<String,CompDetailWraper> attIdMap = new Map<String,CompDetailWraper>();
            for(FL_Upload_Manifest__c mani : [SELECT Id,Component_Type__c,Component_Name__c,File_Name__c,CRC32__c,Changed_On__c,Changed_By__c,(SELECT Id,BodyLength FROM Attachments ORDER BY CreatedDate DESC LIMIT 1) FROM FL_Upload_Manifest__c WHERE Id IN:compLogIds])
            {
                if(mani.attachments.size() == 1)
                {
                    //attIdMap.put(mani.Component_Type__c+'#'+Component_Name__c,mani.attachments[0].Id);
                    CompDetailWraper detail = new CompDetailWraper();
                    detail.fullName = mani.Component_Name__c;
                    detail.fileName = mani.File_Name__c;
                    detail.metaType = mani.Component_Type__c;
                    detail.crcCode = mani.CRC32__c;
                    detail.lastModifiedDate = ''+mani.Changed_On__c;
                    detail.lastModifiedByName = mani.Changed_By__c;
                    detail.commitByUser = UserInfo.getFirstName()+' '+UserInfo.getLastName();
                    detail.committedByUserName = UserInfo.getUserName();
                    attIdMap.put(mani.attachments[0].Id,detail);
                    wrap.fullNames.add(mani.Component_Name__c);
                    wrap.metaTypes.add(mani.Component_Type__c);
                }
            }
            for(Attachment att : [SELECT Id,Body FROM Attachment WHERE Id IN:attIdMap.keySet()])
            {
                CompDetailWraper detail = attIdMap.get(att.Id);
                detail.base64Content = EncodingUtil.base64Encode(att.Body);
                wrap.dataMap.put(detail.metaType+'#'+detail.fullName,detail);
            }
            attIdMap.clear();
            String commitStr = JSON.serialize(wrap);
            wrap = new CommitWraper();
            FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c,cred.Instance_URL__c);
            service.commitToBranch(commitStr,cred.BranchToCommit__c);
            commitStr = null;
            List<FL_Sync__c> syncLi = new List<FL_Sync__c>();
            syncLi = [SELECT Id FROM FL_Sync__c WHERE Id=:syncId LIMIT 1];
            if(syncLi.size() == 1)
            {
                List<FL_Sync_Component__c> compLi = new List<FL_Sync_Component__c>();
                for(FL_Upload_Manifest__c mani : [SELECT Id,Component_Type__c,Component_Name__c,File_Name__c,CRC32__c,Changed_On__c,Changed_By__c FROM FL_Upload_Manifest__c WHERE Id IN:compLogIds])
                {
                    FL_Sync_Component__c comp = new FL_Sync_Component__c();
                    comp.Component_Type__c = mani.Component_Type__c;
                    comp.Component_Name__c = mani.Component_Name__c;
                    comp.File_Name__c = mani.File_Name__c;
                    comp.CRC32__c = mani.CRC32__c;
                    comp.Changed_On__c = mani.Changed_On__c;
                    comp.Changed_By__c = mani.Changed_By__c;
                    comp.Sync__c = syncLi[0].Id;
                    compLi.add(comp);
                }
                if(compLi.size() > 0)
                    insert compLi;
            }
            return 'true';
        }
        else
        {
            throw new FL_FlosumException(FL_LocalFlosumConstants.REGISTER_BRANCH_MESSAGE);
        }
    }
    
    @RemoteAction
    public static CRCResultWraper checkCrcCodeFromFlosum(string commitStr)
    {
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if(cred != null && cred.Id != null && commitStr != null && commitStr != '')
        {
            if(cred.BranchToCommit__c != null && cred.BranchToCommit__c != '')
            {
                FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c,cred.Instance_URL__c);
                String response = service.checkCrcFromBranchAndRemoteRepository(commitStr,cred.BranchToCommit__c);
                commitStr = null;
                CRCResultWraper result = (CRCResultWraper)JSON.deserialize(response, CRCResultWraper.class);
                return result;
            }
            else
            {
                //throw new Exception('');
                throw new FL_FlosumException(FL_LocalFlosumConstants.REGISTER_BRANCH_MESSAGE);
            }
        }
        return new CRCResultWraper();
    }
    
    @RemoteAction
    public static List<CommitStatusWraper> getCommitDetail(String tempLogId)
    {
        List<CommitStatusWraper> result = new List<CommitStatusWraper>();
        for(FL_Upload_Manifest__c mani : [SELECT Id,Component_Name__c,Component_Type__c,Commit_Status__c,Changed_By__c,Changed_On__c,Reason__c,(SELECT Id,BodyLength FROM Attachments ORDER BY CreatedDate DESC LIMIT 1) FROM FL_Upload_Manifest__c WHERE Upload_Log__c=:tempLogId])
        {
            CommitStatusWraper wrap = new CommitStatusWraper();
            wrap.fullName = mani.Component_Name__c;
            wrap.metaType = mani.Component_Type__c;
            wrap.changedOn = ''+mani.Changed_On__c.formatGMT('yyyy-MM-dd hh:mm:ss ')+'GMT';
            wrap.changedBy = mani.Changed_By__c;
            wrap.status = mani.Commit_Status__c;
            wrap.isSafe = false;
            wrap.reason = mani.Reason__c;
            if(mani.attachments != null && mani.attachments.size() == 1)
            {
                wrap.contentLength = mani.attachments[0].BodyLength;
                wrap.compId = mani.Id;
            }
            if(mani.Commit_Status__c == FL_LocalFlosumConstants.SAFE_TO_COMMIT)
                wrap.isSafe = true;
            result.add(wrap);
        }
        return result;
    }
    
    public class FL_FlosumException extends Exception
    {}
    /**************************************************************************/

    @RemoteAction
    public static List<RepositoryComponentWrapper> getComponentsRemoteRepository(String syncCompId, String filterId) {
        List<RepositoryComponentWrapper> compDetails = new List<RepositoryComponentWrapper>();
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if(cred != null && cred.Id != null) {
            DateTime filterDate;
            List<FL_Sync__c> lastSync = [
                SELECT Id, CreatedDate
                FROM FL_Sync__c
                WHERE Succeed__c = true AND Id = :syncCompId
                ORDER BY CreatedDate DESC
                LIMIT 1
            ];
            if(lastSync.size() > 0) {
                filterDate = lastSync[0].CreatedDate;
            }
            FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c, cred.Instance_URL__c);
            String response = service.getRepoComponents(filterDate, filterId);
            String branches = service.listBranches();

            compDetails = (List<RepositoryComponentWrapper>)JSON.deserialize(response, List<RepositoryComponentWrapper>.class);
            response = null;
        }
        return compDetails;
    }

    @RemoteAction
    public static List<LocalComponentWrapper> mergeComponents(String uploadLogId) {
        List<LocalComponentWrapper> result = new List<LocalComponentWrapper>();
        for(FL_Upload_Manifest__c mani : [
            SELECT Id,Component_Name__c,Component_Type__c,Commit_Status__c,Changed_By__c,Changed_On__c,Reason__c,
                (SELECT Id,BodyLength FROM Attachments ORDER BY CreatedDate DESC LIMIT 1)
            FROM FL_Upload_Manifest__c
            WHERE Upload_Log__c=:uploadLogId])
        {
            LocalComponentWrapper wrap = new LocalComponentWrapper();
            wrap.fullName = mani.Component_Name__c;
            wrap.metaType = mani.Component_Type__c;
            wrap.changedOn = ''+mani.Changed_On__c.formatGMT('yyyy-MM-dd hh:mm:ss ')+'GMT';
            wrap.changedBy = mani.Changed_By__c;
            wrap.status = mani.Commit_Status__c;
            wrap.isSafe = false;
            wrap.reason = mani.Reason__c;
            if(mani.attachments != null && mani.attachments.size() == 1)
            {
                wrap.contentLength = mani.attachments[0].BodyLength;
                wrap.compId = mani.Id;
            
            if(mani.Commit_Status__c == FL_LocalFlosumConstants.SAFE_TO_COMMIT)
                wrap.isSafe = true;
            result.add(wrap);
            }
        }
        return result;
    }

    @RemoteAction
    public static List<RepositoryComponentsBranchWrapper> getRemoteBranch(string componStr) {
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if(cred != null && cred.Id != null && componStr != null && componStr != '')
        {
            if(cred.BranchToCommit__c != null && cred.BranchToCommit__c != '')
            {
                FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c,cred.Instance_URL__c);
                String response = service.checkComponentsWithBranch(componStr,cred.BranchToCommit__c);
                componStr = null;
                List<RepositoryComponentsBranchWrapper> result = (List<RepositoryComponentsBranchWrapper>)JSON.deserialize(response, List<RepositoryComponentsBranchWrapper>.class);
                return result;
            }
            else
            {
                throw new FL_FlosumException(FL_LocalFlosumConstants.REGISTER_BRANCH_MESSAGE);
            }
        }
        return new List<RepositoryComponentsBranchWrapper>();
    }

    @RemoteAction
    public static void updateMergeFile(List<List<String>> listAtt) {
        List<Attachment> attList = new List<Attachment>();
        List<Id> attIdList = new List<Id>();
        Map<Id, String> mapIdCRC = new Map<Id, String>();
        for (List<String> attach : listAtt) {
            Attachment att = new Attachment();
            att.Id = attach[1];
            att.Body = EncodingUtil.base64Decode(attach[0]);
            attIdList.add(attach[1]);
            mapIdCRC.put(attach[1], attach[2]);
            //att.CRC32__c
            attList.add(att);
        }

        List<Attachment> listParentIdAtt = [SELECT Id, ParentId FROM Attachment WHERE Id IN: attIdList];
        List<Id> listParentId = new List<Id>();
        if (listParentIdAtt != null && !listParentIdAtt.isEmpty()) {
            for (Attachment parId : listParentIdAtt) {
                listParentId.add(parId.ParentId);
            }
        }

        if (listParentId != null && !listParentId.isEmpty()) {
            List<FL_Upload_Manifest__c> listFUM = [
                SELECT Id, Component_Type__c, Component_Name__c, File_Name__c, CRC32__c, Changed_On__c, Changed_By__c,
                    (SELECT Id FROM Attachments ORDER BY CreatedDate DESC LIMIT 1)
                FROM FL_Upload_Manifest__c
                WHERE Id IN: listParentId
            ];

            if (listFUM != null && !listFUM.isEmpty()) {
                List<FL_Upload_Manifest__c> updFUM = new List<FL_Upload_Manifest__c>();
                for (FL_Upload_Manifest__c fum : listFUM) {
                    FL_Upload_Manifest__c tempUpdFUM = new FL_Upload_Manifest__c();
                    tempUpdFUM.Id = fum.Id;
                    tempUpdFUM.CRC32__c = mapIdCRC.get(fum.attachments[0].Id);

                    updFUM.add(tempUpdFUM);
                }

                if (updFUM != null && !updFUM.isEmpty()) {
                    update updFUM;
                }
            }
        }

        update attList;
    }

    @RemoteAction
    public static String getBranchItems(String branchId, String jsonListBranch) {
        List<RepositoryComponentsBranchWrapper> listBranch = (List<RepositoryComponentsBranchWrapper>)JSON.deserialize(jsonListBranch, List<RepositoryComponentsBranchWrapper>.class);
        List<String> compName = new List<String>();
        for (RepositoryComponentsBranchWrapper sw : listBranch) {
            compName.add(sw.compName);
        }

        List<FL_Upload_Manifest__c> listUM = [
            SELECT Id, Component_Type__c, Component_Name__c, File_Name__c, CRC32__c, Changed_On__c, Changed_By__c,
                (SELECT Id, BodyLength FROM Attachments ORDER BY CreatedDate DESC LIMIT 1)
            FROM FL_Upload_Manifest__c
            WHERE Upload_Log__c = :branchId AND Component_Name__c IN :compName
            ORDER BY Component_Type__c DESC
        ];
        List<Map<String, Object>> returnList = new List<Map<String, Object>>();
        if (listUM != null && !listUM.isEmpty()) {
            for (FL_Upload_Manifest__c mi: listUM) {
                if (mi.attachments.size() == 1) {
                    Map<String, Object> miOb = new Map<String, Object>{
                        'ItemId' => mi.Id,
                        //'RecordTypeId' => mi.RecordTypeId,
                        'ComponentType' => mi.Component_Type__c,
                        'APIName' => mi.Component_Name__c,
                        'Name' => mi.Component_Name__c,
                        'CRC32' => mi.CRC32__c,
                        'AttachmentID' => mi.attachments[0].Id,
                        'Label' => mi.File_Name__c,
                        'Select' => true
                    };
                    returnList.add(miOb);
                }
            }
        }

        return JSON.serialize(returnList);
    }
    
    public static List<RepositoryAttachmentsBranchWrapper> getAttachmentsRemoteBranch(Set<Id> hisId) {
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if (cred != null && cred.Id != null) {
            if (cred.BranchToCommit__c != null && cred.BranchToCommit__c != '') {

                String jsonHisId = JSON.serialize(hisId);

                FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c, cred.Instance_URL__c);
                String response = service.checkAttachmentsWithBranch(jsonHisId, cred.BranchToCommit__c);
                List<RepositoryAttachmentsBranchWrapper> result = (List<RepositoryAttachmentsBranchWrapper>)JSON.deserialize(response, List<RepositoryAttachmentsBranchWrapper>.class);
                return result;
            }
            else
            {
                throw new FL_FlosumException(FL_LocalFlosumConstants.REGISTER_BRANCH_MESSAGE);
            }
        }
        return new List<RepositoryAttachmentsBranchWrapper>();
    }

    public static List<RepositoryAttachmentsBranchWrapper> getAttachmentsRemoteBranchID(List<Id> attId) {
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if (cred != null && cred.Id != null) {
            if (cred.BranchToCommit__c != null && cred.BranchToCommit__c != '') {

                String jsonHisId = JSON.serialize(attId);

                FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c, cred.Instance_URL__c);
                String response = service.checkAttachmentsWithBranchID(jsonHisId, cred.BranchToCommit__c);
                List<RepositoryAttachmentsBranchWrapper> result = (List<RepositoryAttachmentsBranchWrapper>)JSON.deserialize(response, List<RepositoryAttachmentsBranchWrapper>.class);
                return result;
            }
            else
            {
                throw new FL_FlosumException(FL_LocalFlosumConstants.REGISTER_BRANCH_MESSAGE);
            }
        }
        return new List<RepositoryAttachmentsBranchWrapper>();
    }

    public static List<PatchManifestWrapper> getPatchRemoteBranch(Set<Id> compHis, String mapCRC32InBranch, String orgId) {
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if (cred != null && cred.Id != null) {
            if (cred.BranchToCommit__c != null && cred.BranchToCommit__c != '') {

                String jsonCompHis = JSON.serialize(compHis);
                FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c, cred.Instance_URL__c);
                String response = service.checkPatchRemoteBranch(jsonCompHis, mapCRC32InBranch, orgId);
                List<PatchManifestWrapper> result = (List<PatchManifestWrapper>)JSON.deserialize(response, List<PatchManifestWrapper>.class);
                return result;
            }
            else
            {
                throw new FL_FlosumException(FL_LocalFlosumConstants.REGISTER_BRANCH_MESSAGE);
            }
        }
        return new List<PatchManifestWrapper>();
    }

    public static List<ComponentHistoryWrapper> getComponentHistoryRemoteBranch(Set<Id> compInfo) {
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if (cred != null && cred.Id != null) {
            if (cred.BranchToCommit__c != null && cred.BranchToCommit__c != '') {

                String jsonId = JSON.serialize(compInfo);

                FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c, cred.Instance_URL__c);
                String response = service.checkComponentHistoryRemoteBranch(jsonId, cred.BranchToCommit__c);
                List<ComponentHistoryWrapper> result = (List<ComponentHistoryWrapper>)JSON.deserialize(response, List<ComponentHistoryWrapper>.class);
                return result;
            }
            else
            {
                throw new FL_FlosumException(FL_LocalFlosumConstants.REGISTER_BRANCH_MESSAGE);
            }
        }
        return new List<ComponentHistoryWrapper>();
    }

    @RemoteAction
    public static String FirstStepMerge(String branchId, List<String> itemsId, String jsonListSnapshot) {
        List<RepositoryComponentsBranchWrapper> listMI = (List<RepositoryComponentsBranchWrapper>)JSON.deserialize(jsonListSnapshot, List<RepositoryComponentsBranchWrapper>.class);
        List<Id> remoteHisId = new List<Id>();
        List<String> remoteName = new List<String>();

        Map<String, RepositoryComponentsBranchWrapper> mapTypePlusNameMI = new Map<String, RepositoryComponentsBranchWrapper>();
        Map<Id, Id> mapCHAtachment = new Map<Id, Id>();
        Map<Id, Id> mapCHAtachmentRemote = new Map<Id, Id>();

        for (RepositoryComponentsBranchWrapper mi: listMI) {
            mapTypePlusNameMI.put(mi.compType + '-' + mi.compName, mi);
            remoteHisId.add(mi.hisId);
            remoteName.add(mi.compName);
        }

        List<FL_Upload_Manifest__c> listLocalComponent = [
            SELECT Id, Component_Type__c, Component_Name__c, File_Name__c, CRC32__c, Changed_On__c, Changed_By__c,
                (SELECT Id, BodyLength FROM Attachments ORDER BY CreatedDate DESC LIMIT 1)
            FROM FL_Upload_Manifest__c
            WHERE Upload_Log__c = :branchId AND Id IN :itemsId
            ORDER BY Component_Type__c DESC
        ];
        
        /*********/
        List<Component__c> listVersionLocalComponent = new List<Component__c>();
        listVersionLocalComponent = [
            SELECT Id, Component_Name__c, Component_Type__c, Version__c, CRC32__c, File_Name__c FROM Component__c WHERE Component_Name__c IN :remoteName
        ];
        Map<String, Component__c> mapTypePlusNameLocalVersion = new Map<String, Component__c>();
        for (Component__c liV: listVersionLocalComponent) {
            mapTypePlusNameLocalVersion.put(liV.Component_Type__c + '-' + liV.Component_Name__c, liV);
        }
        /*********/

        String jsonName = JSON.serialize(remoteName);
        List<RepositoryComponentsBranchWrapper> listRemoveComponent = getRemoteBranch(jsonName);

        Map<String, FL_Upload_Manifest__c> mapTypePlusNameComponentLocal = new Map<String, FL_Upload_Manifest__c>();
        Map<Id, Decimal> mapLastDeplotedVersionComponent = new Map<Id, Decimal>();
        if (listLocalComponent != null && !listLocalComponent.isEmpty()) {
            for (FL_Upload_Manifest__c c: listLocalComponent) {
                String Key = c.Component_Type__c + '-' + c.Component_Name__c;
                mapTypePlusNameComponentLocal.put(Key, c);
                if (mapTypePlusNameLocalVersion.get(Key) != null) {
                    Component__c locVers = mapTypePlusNameLocalVersion.get(Key);
                    mapLastDeplotedVersionComponent.put(c.Id, locVers.Version__c);
                }
                //mapLastVersionComponent.put(c.Id, c.version);
                //mapLastVersionComponent.put(c.Id, 1);
            }
        }
        Map<String, RepositoryComponentsBranchWrapper> mapTypePlusNameComponentRemove = new Map<String, RepositoryComponentsBranchWrapper>();
        Map<Id, Decimal> mapLastVersionComponentRemove = new Map<Id, Decimal>();
        if (listRemoveComponent != null && !listRemoveComponent.isEmpty()) {
            for (RepositoryComponentsBranchWrapper c: listRemoveComponent) {
                String Key = c.compType + '-' + c.compName;
                mapTypePlusNameComponentRemove.put(Key, c);
                mapLastVersionComponentRemove.put(c.compId, c.version);
                //mapLastVersionComponentRemove.put(c.Id, 1);
            }
        }
        //System.debug('IIII mapTypePlusNameComponentRemove - \n\n' + mapTypePlusNameComponentRemove);
    
        String Key;

        Set<Id> ComponentLocalIds = new Set<Id>();
        for (FL_Upload_Manifest__c mi: listLocalComponent) {
            Key = mi.Component_Type__c + '-' + mi.Component_Name__c;
            if (mapTypePlusNameComponentLocal.get(Key) != null) {
                FL_Upload_Manifest__c findCompLoc = mapTypePlusNameComponentLocal.get(Key);
                ComponentLocalIds.add(findCompLoc.Id);
            }
        }

        Set<Id> ComponentRemoveIds = new Set<Id>();
        for (RepositoryComponentsBranchWrapper mi: listRemoveComponent) {
            Key = mi.compType + '-' + mi.compName;
            if (mapTypePlusNameComponentRemove.get(Key) != null) {
                RepositoryComponentsBranchWrapper findCompRem = mapTypePlusNameComponentRemove.get(Key);
                ComponentRemoveIds.add(findCompRem.compId);
            }
        }

        //System.debug('IIII ComponentIds - \n\n' + ComponentIds);

        //search History
        Set<Id> AllComponentHistory = new Set<Id>();
        //Map<Id, List<ComponentHistoryWrapper>> mapHistory = new Map<Id, List<ComponentHistoryWrapper>>();
        Map<Id, ComponentHistoryWrapper> mapHistory = new Map<Id, ComponentHistoryWrapper>();
        Map<Id, ComponentHistoryWrapper> mapLastHistory = new Map<Id, ComponentHistoryWrapper>();
        Set<Id> SetCMForAttachment = new Set<Id>();
        Map<String, ComponentHistoryWrapper> mapCRC32InBranch = new Map<String, ComponentHistoryWrapper>();
        if (!ComponentRemoveIds.isEmpty()) {
            List<ComponentHistoryWrapper> listCH = getComponentHistoryRemoteBranch(ComponentRemoveIds);
            if (listCH != null && !listCH.isEmpty()) {
                for (ComponentHistoryWrapper ch: listCH) {
                    Decimal LastVersin = mapLastVersionComponentRemove.get(ch.component);
                    if (LastVersin == ch.version) {
                        mapLastHistory.put(ch.component, ch);
                        SetCMForAttachment.add(ch.Id);
                    }
                    AllComponentHistory.add(ch.Id);
                    mapCRC32InBranch.put(ch.CRC32, ch);


                    if (mapTypePlusNameLocalVersion.get(Key) != null && mapTypePlusNameLocalVersion.get(Key).Version__c == ch.version) {
                        mapHistory.put(ch.component, ch);
                        SetCMForAttachment.add(ch.Id);
                    }
                }
            }
        }

                //getAttachment Component History
        List<Attachment> listAttachment = [SELECT Id, ParentId, CreatedDate FROM Attachment WHERE ParentId IN: ComponentLocalIds];
        if (listAttachment != null && !listAttachment.isEmpty()) {
            for (Attachment at : listAttachment) {
                mapCHAtachment.put(at.ParentId, at.Id);
            }
        }
        List<RepositoryAttachmentsBranchWrapper> listAttachmentRemote = getAttachmentsRemoteBranch(SetCMForAttachment);
        if (listAttachmentRemote != null && !listAttachmentRemote.isEmpty()) {
            for (RepositoryAttachmentsBranchWrapper at : listAttachmentRemote) {
                mapCHAtachmentRemote.put(at.ParentId, at.Id);
            }
        }

        //analitics
        List<Map<String, Object>> returnInfo = new List<Map<String, Object>>();
        
        for (FL_Upload_Manifest__c mi: listLocalComponent) {
            Key = mi.Component_Type__c + '-' + mi.Component_Name__c;
            Map<String, Object> item = new Map<String, Object>();
            item.put('ItemId', mi.Id);
            item.put('ComponentType', mi.Component_Type__c);
            item.put('APIName', mi.Component_Name__c);
            item.put('Label', mi.File_Name__c);
            item.put('AttachmentId', mapCHAtachment.get(mi.Id));
            item.put('CRC32', mi.CRC32__c);
            item.put('ChangedBy', mi.Changed_By__c);
            if (mapTypePlusNameComponentRemove.get(Key) != null) {
                RepositoryComponentsBranchWrapper findComp = mapTypePlusNameComponentRemove.get(Key);
                if (mapLastHistory.get(findComp.compId) != null) {
                    ComponentHistoryWrapper lastHistory = mapLastHistory.get(findComp.compId);
                    item.put('LastComponentHistoryId', lastHistory.Id);
                    item.put('LastComponentHistoryCRC32', lastHistory.CRC32);
                    item.put('LastComponentHistoryVersion', lastHistory.version);
                    item.put('LastComponentHistoryChangedOn', lastHistory.changedOn);
                    item.put('LastComponentHistoryChangedBy', lastHistory.changedBy);
                    item.put('LastComponentHistoryATID', mapCHAtachmentRemote.get(lastHistory.Id));
                    
                }
                item.put('inBranch', true);
                item.put('VersionInBranch', findComp.version);
                if (mapHistory.get(findComp.compId)  != null) {
                //if (mapDeployComponent.get(findComp.compId)  != null) {
                    item.put('Deployed', true);
                    //PatchManifestWrapper pm = mapDeployComponent.get(findComp.compId);
                    //if (pm.developerName == 'Repository') {
                    //    ComponentHistoryWrapper chInBranch = mapCRC32InBranch.get(pm.historyCRC32);
                        ComponentHistoryWrapper history = mapHistory.get(findComp.compId);
                        item.put('DeployedComponentHistoryId', history.Id);
                        item.put('DeployedComponentHistoryATID', mapCHAtachmentRemote.get(history.Id));
                        item.put('IsLastVersion', history.version == findComp.version);
                        item.put('DeployedComponentHistoryVersion', history.version);
                        item.put('DeployedComponentHistoryCRC32', history.CRC32);
                        item.put('DeployedComponentHistoryLastDate', '');
                }
                else {
                    item.put('Deployed', false);
                }
            }
            else {
                item.put('inBranch', false);
                item.put('Deployed', false);
            }
            returnInfo.add(item);
        }

        return JSON.serialize(returnInfo);
    }
    
    @RemoteAction
    public static List<AttachmentWraper> getLastAndDeployAtachment(String LastId, String DeployId) {
        
        List<String> listAttId = new List<String>();
        if (!String.isBlank(LastId)) {
            listAttId.add(LastId);
        }
        if (!String.isBlank(DeployId)) {
            listAttId.add(DeployId);
        }

        List<AttachmentWraper> wrapList = new List<AttachmentWraper>();
        List<RepositoryAttachmentsBranchWrapper> attList = getAttachmentsRemoteBranchID(listAttId);

        for(RepositoryAttachmentsBranchWrapper att : attList) {
            AttachmentWraper wrap = new AttachmentWraper();
            wrap.Id = att.Id;
            Id IdLast = Id.valueOf(LastId);
            if (IdLast == att.Id) {
                wrap.TypeAtt = 'Last';
            }
            else {
                wrap.TypeAtt = 'Deploy';
            }
            wrap.compType = att.compType;    //CustomObject
            wrap.base64 = att.base64;
            wrapList.add(wrap);
        }


        return wrapList;
    }
    
    @RemoteAction
    public static AttachmentWraper getMetaItemAtachment(String Atachment) {
        Attachment att  = [SELECT Id,Body,Description FROM Attachment WHERE Id =:Atachment];
        AttachmentWraper wrap = new AttachmentWraper();
        wrap.Id = att.Id;
        wrap.compType = att.Description;    //CustomObject
        wrap.base64 = EncodingUtil.base64Encode(att.Body);
        return wrap;
    }

    public class AttachmentWraper
    {   public String TypeAtt;
        public String Id;   //a0Iq00000012tdzEAA
        public String compType; //CustomObject
        public String base64;
    }
    
    public class RepositoryComponentsBranchWrapper {
        public Id compId;
        public String compName;
        public String compType;
        public String reason;
        public Decimal version;
        public Id hisId;
        
        public String compCRC;
        public String changedBy;
        public String changedOn;
        public String committedBy;
        public String committedOn;
        public String fileName;
        public Integer contentSize;
        public String contentId;
    }
    
    
    public class RepositoryAttachmentsBranchWrapper {
        public String TypeAtt;
        public String Id; //attId
        public String parentId;
        public String compType; //description;
        public String base64; //attBody;
        
    }

    public class PatchManifestWrapper {
        public String Id;
        public String Patch;
        public String componentHistory;
        public String component;
        public DateTime lastUpdatedOn;
        public String attachmentID;
        public Decimal historyVersion;
        public String historyCRC32;
        public String branch;
        public String developerName;
    }

    public class ComponentHistoryWrapper {
        public String Id;
        public DateTime changedOn;
        public String changedBy;
        public String component;
        public Decimal version;
        public String CRC32;
        public String compName;
        public String compType;
    }

    public class ComponentWraper 
    {
        public List<String> fullNames;
        public List<String> metaTypes;
    }

    public class LocalComponentWrapper
    {
        public String fullName;  
        public String fileName;
        public String metaType;
        public String status;
        public String changedOn;
        public String changedBy;
        public boolean isSafe;
        public String reason;
        public Decimal version;
        public Integer contentLength;
        public String compId;
    }

    public class RepositoryComponentWrapper {
        public Id compId;
        public String compName;
        public String compType;
        public String compCRC;
        public String changedBy;
        public String changedOn;
        public String committedBy;
        public String committedOn;
        public String fileName;
        public Decimal version;
        public Integer contentSize;
        public String contentId;
    }
    /**************************************************/
    

    public class CommitStatusWraper
    {
        public String fullName;  
        public String fileName;
        public String metaType;
        public String status;
        public String changedOn;
        public String changedBy;
        public boolean isSafe;
        public String reason;
        public Decimal version;
        public Integer contentLength;
        public String compId;
    }

    public class CompDetailWraper 
    {
        public String fullName;  
        public String fileName;
        public String metaType;
        public String crcCode;
        public String lastModifiedDate;
        public String lastModifiedByName;
        public String base64Content;
        public String reason;
        public Decimal version;
        public String commitByUser;
        public String committedByUserName;
    }
    
    public class CommitWraper 
    {
        public List<String> fullNames;
        public List<String> metaTypes;
        public Map<String,CompDetailWraper> dataMap;
        
        public CommitWraper()
        {
            this.fullNames = new List<String>();
            this.metaTypes = new List<String>();
            this.dataMap = new Map<String,CompDetailWraper>();
        }
    }
    
    public class CRCResultWraper
    {
        public List<SafeToCommitWraper> safeToCommit;
        public List<NotToCommitWraper> notToCommit;
    }
    
    public class SafeToCommitWraper
    {
        public String compName;
        public String compType;
    }
    
    public class NotToCommitWraper
    {
        public String compName;
        public String compType;
        public String reason;
        public Decimal version;
    }
}