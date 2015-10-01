public class BatchAnonymizeContacts implements Database.Batchable<SObject> { 
	
	private BatchAnonymizeContacts() { }
	
	String prefix;
	String domain;
	public BatchAnonymizeContacts(String prefix, String domain) {
		this.prefix = prefix;
		this.domain = domain; 
	} 
	
	public Database.QueryLocator start(Database.BatchableContext bc) { 
		return Database.getQueryLocator([SELECT Id, Name, Email FROM Contact WHERE Email != null]); 
	}
	
	// This does the actual work; creating payment transaction records for purchaces and refunds 
	public void execute(Database.BatchableContext bc, List<Contact> cList) { 
		for (Contact c : cList) {
			if (!String.isBlank(c.Email)) {
				c.Email = Anonymizer.getAnonymizedEmail(c.Email, prefix, domain);
			}
		}
		update cList; 
	}
	
	public void finish(Database.BatchableContext bc) { 
		// Query the AsyncApexJob object to retrieve the current job's information. 
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :bc.getJobId()]; 
		
		// Send an email to the Apex job's submitter notifying of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
		String[] toAddresses = new String[] { a.CreatedBy.Email }; 
		mail.setToAddresses(toAddresses); 
		mail.setSubject('BatchAnonymizeContacts: ' + a.Status); 
		mail.setPlainTextBody('The BatchAnonymizeContacts job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
	}
}