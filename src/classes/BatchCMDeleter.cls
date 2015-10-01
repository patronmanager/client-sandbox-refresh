// Batch deletion of Campaign Member objects. 
// Use this to free up space within the sandbox when it hits the data storage limit
// Usage: Database.executeBatch(new BatchCMDeleter(), 5000); 
public without sharing class BatchCMDeleter implements Database.Batchable<sObject>, Database.Stateful {
	
	public BatchCMDeleter() { }
	
	public Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator([SELECT Id FROM CampaignMember]);
	}
	
	public void execute(Database.BatchableContext context, List<sObject> objList) {
		delete objList;
	}
	
	public void finish(Database.BatchableContext context) {
	}
}