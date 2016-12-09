trigger BranchTrigger on Branch__c (before delete,before insert,before update) 
{
	if(Trigger.IsBefore)
	{
		BranchTriggerHandler handler = new BranchTriggerHandler();
		if(Trigger.IsDelete)
		{
			handler.deleteBranchComponents(Trigger.oldMap);
		}
		else if(Trigger.IsInsert)
		{
			handler.checDuplicate(Trigger.New);
		}
		else if(Trigger.IsUpdate)
		{
			handler.updateHandler(Trigger.New,Trigger.oldMap);
		}
	}
}