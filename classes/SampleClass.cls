public class GIT_MetaItem {
   	public String mLabel {get;set;}
	public String name {get;set;}
	public String cname {get;set;}
	public String data {get;set;}
    public Integer lastModified {get;set;}

    public 	GIT_MetaItem(){
    }
    
    public 	GIT_MetaItem(String mLabel, String name, String data, Integer lastModified){
        this.mLabel = mLabel;
        this.name = name;
        this.data = data;
        this.lastModified = lastModified;
    }

}