public with sharing class FL_CustomLookupController 
{
    public String metaStr{get; set;}
    public List<MetaTypeWraper> metatypesList{get; set;}
    public String fieldName{get; private set;}
    public Integer filterIndex{get; private set;}
    public Set<String> existingSet;
    
    public FL_CustomLookupController()
    {
        metatypesList = new List<MetaTypeWraper>();
        existingSet = new Set<String>();
        try
        {
            fieldName = ApexPages.currentpage().getparameters().get('fieldName');
            filterIndex = Integer.valueOf(ApexPages.currentpage().getparameters().get('filterIndex'));
            String fieldValues = ApexPages.currentpage().getparameters().get('fieldValue');
            if(fieldValues != null)
            {
                for(String str : fieldValues.split(','))
                    existingSet.add(str);
            }
        }
        catch(Exception ex)
        {
            System.debug(ex.getMessage());
        }
    }
    
    public void listMetadataTypes()
    {
        metatypesList.clear();
        if(metaStr != null && metaStr != '')
        {
            try
            {
                if(fieldName == 'type')
                {
                    List<String> wrapInfo = (List<String>) JSON.deserialize(metaStr, List<String>.class);
                    for(String metadataTypeName : wrapInfo)
                    {
                        System.debug(metadataTypeName);
                        if(existingSet.contains(metadataTypeName))
                            metatypesList.add(new MetaTypeWraper(true,metadataTypeName));
                        else
                            metatypesList.add(new MetaTypeWraper(false,metadataTypeName));
                    }
                }
                else if(fieldName == 'lastModifiedByName' || fieldName == 'createdByName')
                {
                    for(User use:[SELECT Id, FirstName,LastName FROM User LIMIT 1000])
                    {
                        if(existingSet.contains(use.FirstName+' '+use.LastName))
                            metatypesList.add(new MetaTypeWraper(true,use.FirstName+' '+use.LastName));
                        else
                            metatypesList.add(new MetaTypeWraper(false,use.FirstName+' '+use.LastName));
                    }
                }
            }
            catch(Exception ex)
            {
                System.debug(ex.getMessage());
            }
        }
    }
    
    public class MetaTypeWraper
    {
        public boolean selected{get; set;}
        public String metatype{get; set;}
        
        public MetaTypeWraper(boolean selected,String metatype)
        {
            this.selected = selected;
            this.metatype = metatype;
        }
    }
}