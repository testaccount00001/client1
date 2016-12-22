public with sharing class FL_RemoteRepositoryController 
{
    public FL_Flosum_Org__c credUpdate;
    public boolean isAuthSuccessful {get; private set;}
    public Integer localApiVersion{get; private set;}

    public String syncName {get; set;}
    public String logRecordId{get; set;}
    public boolean IsSuccessDeployment{get; set;}
    public String tempRemComp;
    public Component__c lastModifiedFrom{get; set;}
    public boolean previousSyncRecordFound{get; set;}
    
    public String localZoneStr{get;set;}
    public boolean IsDeployOnlyPackagePermission{get; set;}

    public String localUser{get;set;}
    public String downloadChangesFrom{get;set;}
    
    public FL_RemoteRepositoryController() 
    {
        localUser = UserInfo.getName();
        previousSyncRecordFound = false;
        IsDeployOnlyPackagePermission = true;
        FL_Deployment_Settings__c deploySettings = FL_Deployment_Settings__c.getOrgDefaults();
        if(deploySettings.Id != null && deploySettings.Deploy_Only_Package_Permissions__c != null)
            IsDeployOnlyPackagePermission = deploySettings.Deploy_Only_Package_Permissions__c;
        
        lastModifiedFrom = new Component__c();
        lastModifiedFrom.Changed_On__c = System.now().addDays(-14);
        List<FL_Sync__c> lastSync = [Select Id, CreatedDate From FL_Sync__c Where Succeed__c=true AND Sync_Type__c= :FL_LocalFlosumConstants.SYNC_TYPE_DOWNLOAD ORDER BY CreatedDate Desc LIMIT 1];
        if(lastSync.size() > 0)
        {
            previousSyncRecordFound = true;
            lastModifiedFrom.Changed_On__c = lastSync[0].CreatedDate;
        } 
        localZoneStr = UserInfo.getTimeZone().getID();
        syncName = System.now().format('YYYY-MM-dd HH:mm')+' Download'; 
        localApiVersion = 36;
        isAuthSuccessful = false;
        credUpdate = FL_Flosum_Org__c.getOrgDefaults();
    }
    
    public void startDownloadChanges()
    {
        try
        {
            downloadChangesFrom = lastModifiedFrom.Changed_On__c.formatGMT('yyyy-MM-dd hh:mm:ss ')+'GMT';
            System.debug(downloadChangesFrom);
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
            downloadChangesFrom = '';
        }
    }
    
    public PageReference redirectToLog()
    {
        List<FL_Sync__c> logList = new List<FL_Sync__c>();
        logList = [SELECT Id,Job_Completed__c,Succeed__c FROM FL_Sync__c WHERE Id=:logRecordId];
        if(logList.size() == 1)
        {
            logList[0].Job_Completed__c = true;
            logList[0].Succeed__c = IsSuccessDeployment;
            update logList;
            return new PageReference('/'+logList[0].Id);
        }
        return null;
    }
    
    public void checkAuthentication()
    {
        isAuthSuccessful = false;
        FL_Credentials__c credentials = FL_Credentials__c.getOrgDefaults();
        if(credUpdate != null && credUpdate.Id != null && credentials != null && credentials.Id != null)
        {
            try
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
                System.debug(resp);
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
                            getApiVersionFromFlosum();
                            update credUpdate;
                            isAuthSuccessful = true;
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Authentication Successful.'));
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
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,FL_LocalFlosumConstants.REGISTER_FLOSUM_ORG_MESSAGE));
        }
    }
    
    public void getApiVersionFromFlosum()
    {
        if(credUpdate != null && credUpdate.Id != null )
        {
            FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(credUpdate.Access_Token__c,credUpdate.Instance_URL__c);
            localApiVersion = service.getBaseAPIVersion();
        }
    }
    
    @RemoteAction
    public static List<RepositoryComponentWrapper> getComponents(String filterId, String recieveChangesFrom) 
    {
        List<RepositoryComponentWrapper> compDetails = new List<RepositoryComponentWrapper>();
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if(cred != null && cred.Id != null)
        {
            DateTime filterDate;
            if(recieveChangesFrom != null && recieveChangesFrom != '')
                filterDate = DateTime.valueOfGmt(recieveChangesFrom.replace('T',' '));//DateTime.parse(recieveChangesFrom);
            else
            {
                List<FL_Sync__c> lastSync = [Select Id, CreatedDate From FL_Sync__c Where Succeed__c=true AND Sync_Type__c= :FL_LocalFlosumConstants.SYNC_TYPE_DOWNLOAD ORDER BY CreatedDate Desc LIMIT 1];
                if(lastSync.size() > 0)
                {
                    filterDate = lastSync[0].CreatedDate;
                }
            }
            FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c, cred.Instance_URL__c);
            String response = service.getRepoComponents(filterDate, filterId);
            compDetails = (List<RepositoryComponentWrapper>)JSON.deserialize(response, List<RepositoryComponentWrapper>.class);
            response = null;
        }
        return compDetails;
    }
    
    @RemoteAction  
    public static List<ContentWraper> getAttachmentContent(List<String> attachIds, String mergeFilesMap) 
    {
        Map<String, String> filesMap = new  Map<String, String>();
        filesMap = (Map<String, String>)JSON.deserialize(mergeFilesMap, Map<String, String>.class);
        List<ContentWraper> compDetails = new List<ContentWraper>();
        FL_Flosum_Org__c cred = FL_Flosum_Org__c.getOrgDefaults();
        if(cred != null && cred.Id != null)
        {
            FL_FlosumService.FlosumExtService service = FL_FlosumUtil.createService(cred.Access_Token__c, cred.Instance_URL__c);
            String response = service.getContentOfComponents(attachIds);
            compDetails = (List<ContentWraper>)JSON.deserialize(response, List<ContentWraper>.class);
            response = null;
        }

        for (ContentWraper compD : compDetails) {
            if (filesMap.get(compD.contentId) != null) {
                compD.base64 = filesMap.get(compD.contentId);
            }
        }
        return compDetails;
    }

    public class FL_FlosumException extends Exception
    {}
    
    @RemoteAction
    public static String createSyncRecords(String syncId,String syncJSON,String syncName)
    {
        if(syncId == '')
        {
            if(syncName != null && syncName != '')
            {
                FL_Sync__c sync = new FL_Sync__c();
                sync.Sync_Type__c = FL_LocalFlosumConstants.SYNC_TYPE_DOWNLOAD;
                sync.Name = syncName;
                insert sync;
                syncId = sync.Id;
            }
            else
            {
                throw new FL_FlosumException('Please enter sync name.');
            }
        }
        List<FL_Sync__c> syncLi = new List<FL_Sync__c>();
        syncLi = [SELECT Id FROM FL_Sync__c WHERE Id=:syncId LIMIT 1];
        if(syncLi.size() == 1)
        {
            List<DonwnloadCompWraper> downloadLi = (List<DonwnloadCompWraper>) JSON.deserialize(syncJSON, List<DonwnloadCompWraper>.class);
            if(downloadLi != null)
            {
                List<FL_Sync_Component__c> compLi = new List<FL_Sync_Component__c>();
                for(DonwnloadCompWraper mani : downloadLi)
                {
                    FL_Sync_Component__c comp = new FL_Sync_Component__c();
                    comp.Component_Type__c = mani.compType;
                    comp.Component_Name__c = mani.compName;
                    comp.File_Name__c = mani.fileName;
                    comp.CRC32__c = mani.compCRC;
                    comp.Changed_On__c = mani.changedOn!=null ? DateTime.valueOfGmt(mani.changedOn) : System.now();
                    comp.Changed_By__c = mani.changedBy;
                    comp.Sync__c = syncLi[0].Id;
                    compLi.add(comp);
                }
                if(compLi.size() > 0)
                    insert compLi;
            }
        }
        return syncId;
    }

    /*************************************************************/

    @RemoteAction
    public static void updateVersionComponent(String strComponents) 
    {
        List<String> namesComp = new List<String>();
        List<UpdateVersionComponentWrapper> listCompWrap = (List<UpdateVersionComponentWrapper>)JSON.deserialize(strComponents, List<UpdateVersionComponentWrapper>.class);
        for (UpdateVersionComponentWrapper updComp : listCompWrap) {
            updComp.compId = '';
            namesComp.add(updComp.compName);
        }

        List<Component__c> listComp = [SELECT Id, Component_Name__c, Component_Type__c FROM Component__c WHERE Component_Name__c IN :namesComp];
        Map<String, Id> mapComp = new Map<String, Id>();
        for (Component__c comp : listComp) {
            mapComp.put(comp.Component_Name__c + '#' + comp.Component_Type__c, comp.Id);
        }

        List<Component__c> listUpdComp = new List<Component__c>();
        for (UpdateVersionComponentWrapper updComp : listCompWrap) {
            Component__c tempComp = new Component__c();
            if (mapComp.get(updComp.compName + '#' + updComp.compType) != null) {
                tempComp.Id = mapComp.get(updComp.compName + '#' + updComp.compType);
            }
            tempComp.Component_Name__c = updComp.compName;
            tempComp.Component_Type__c = updComp.compType;
            tempComp.Last_Updated_By__c = updComp.changedBy;
            tempComp.Changed_On__c = updComp.changedOn!=null ? DateTime.valueOfGmt(updComp.changedOn) : System.now();
            tempComp.Last_Modified_By__c = updComp.committedBy;
            tempComp.Committed_On__c = updComp.committedOn!=null ? DateTime.valueOfGmt(updComp.committedOn) : System.now();
            tempComp.CRC32__c = updComp.compCRC;
            tempComp.File_Name__c = updComp.fileName;
            tempComp.Version__c = updComp.version;

            listUpdComp.add(tempComp);
        }

        upsert listUpdComp;
    }

    //@RemoteAction
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

    @RemoteAction
    //public static String FirstStepMerge(String branchId, List<String> itemsId, String jsonList) {
    public static String FirstStepMerge(String jsonList) {
        List<UpdateVersionComponentWrapper> listMI = (List<UpdateVersionComponentWrapper>)JSON.deserialize(jsonList, List<UpdateVersionComponentWrapper>.class);
        List<String> remoteName = new List<String>();

        Map<Id, Id> mapCHAtachment = new Map<Id, Id>();
        Map<Id, Id> mapCHAtachmentRemote = new Map<Id, Id>();

        for (UpdateVersionComponentWrapper mi: listMI) {
            remoteName.add(mi.compName);
        }

        List<Component__c> listLocalComponent = new List<Component__c>();
        listLocalComponent = [
            SELECT Id, Component_Name__c, Component_Type__c, Version__c, CRC32__c, File_Name__c FROM Component__c WHERE Component_Name__c IN :remoteName
        ];
        
        String jsonName = JSON.serialize(remoteName);
        List<RepositoryComponentsBranchWrapper> listRemoveComponent = getRemoteBranch(jsonName);

        Map<String, Component__c> mapTypePlusNameComponentLocal = new Map<String, Component__c>();
        Map<Id, Decimal> mapLastVersionComponent = new Map<Id, Decimal>();
        if (listLocalComponent != null && !listLocalComponent.isEmpty()) {
            for (Component__c c: listLocalComponent) {
                String Key = c.Component_Type__c + '-' + c.Component_Name__c;
                mapTypePlusNameComponentLocal.put(Key, c);
                mapLastVersionComponent.put(c.Id, c.Version__c);
            }
        }
        Map<String, RepositoryComponentsBranchWrapper> mapTypePlusNameComponentRemove = new Map<String, RepositoryComponentsBranchWrapper>();
        Map<Id, Decimal> mapLastVersionComponentRemove = new Map<Id, Decimal>();
        if (listRemoveComponent != null && !listRemoveComponent.isEmpty()) {
            for (RepositoryComponentsBranchWrapper c: listRemoveComponent) {
                String Key = c.compType + '-' + c.compName;
                mapTypePlusNameComponentRemove.put(Key, c);
                mapLastVersionComponentRemove.put(c.compId, c.version);
            }
        }
    
        String Key;

        Set<Id> ComponentLocalIds = new Set<Id>();
        for (Component__c mi: listLocalComponent) {
            Key = mi.Component_Type__c + '-' + mi.Component_Name__c;
            if (mapTypePlusNameComponentLocal.get(Key) != null) {
                Component__c findCompLoc = mapTypePlusNameComponentLocal.get(Key);
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

                    
                    if (mapTypePlusNameComponentLocal.get(ch.compType + '-' + ch.compName) != null && mapTypePlusNameComponentLocal.get(ch.compType + '-' + ch.compName).Version__c == ch.version) {
                        mapHistory.put(ch.component, ch);
                        SetCMForAttachment.add(ch.Id);
                    }
                }
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
        //for (Component__c mi: listLocalComponent) {
        for (UpdateVersionComponentWrapper mi: listMI) {
            Key = mi.compType + '-' + mi.compName;
            Map<String, Object> item = new Map<String, Object>();
            item.put('ItemId', mi.compId);
            item.put('ComponentType', mi.compType);
            item.put('APIName', mi.compName);
            item.put('Label', mi.fileName);
            item.put('AttachmentId', '');
            item.put('Attachment', mi.base64content);
            item.put('CRC32', '');
            item.put('ChangedBy', mi.changedBy);
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
                    item.put('Deployed', true);
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

        System.debug('IIII \n\n' + returnInfo);
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

    public class UpdateVersionComponentWrapper 
    {
        public String compId;
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
        public String base64content;
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

    public class RepositoryAttachmentsBranchWrapper {
        public String TypeAtt;
        public String Id; //attId
        public String parentId;
        public String compType; //description;
        public String base64; //attBody;
    }

    public class AttachmentWraper
    {   public String TypeAtt;
        public String Id;   //a0Iq00000012tdzEAA
        public String compType; //CustomObject
        public String base64;
    }

    /*********************************************************/
    public class RepositoryComponentWrapper 
    {
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
    
    public class DonwnloadCompWraper
    {
        public String Status;
        public String changedBy;
        public String changedOn;
        public String committedBy;
        public String committedOn;
        public String compCRC;
        public String compName;
        public String compType;
        public String fileName;
    }
    
    public class ContentWraper
    {
        public String parentId;
        public String compType;
        public String base64;
        public String contentId;
    }
}