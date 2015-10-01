public class BatchAnonymizeTicketOrders implements Database.Batchable<SObject> { 

	private BatchAnonymizeTicketOrders() { }
	
	String prefix;
	String domain;
	public BatchAnonymizeTicketOrders(String prefix, String domain) {
		this.prefix = prefix;
		this.domain = domain; 
	}
	
	public Database.QueryLocator start(Database.BatchableContext bc) { 
		return Database.getQueryLocator([SELECT Id, Name, PatronTicket__PaymentTransactionId__c, PatronTicket__Email__c FROM PatronTicket__TicketOrder__c]);
	}
	
	// This does the actual work; creating payment transaction records for purchaces and refunds 
	public void execute(Database.BatchableContext bc, List<PatronTicket__TicketOrder__c> orderList) {
		for (PatronTicket__TicketOrder__c ticketOrder : orderList) {
			if (!String.isBlank(ticketOrder.PatronTicket__Email__c)) {
				ticketOrder.PatronTicket__Email__c = Anonymizer.getAnonymizedEmail(ticketOrder.PatronTicket__Email__c, prefix, domain);
			}
			ticketOrder.PatronTicket__PaymentTransactionId__c = null;
		} 
		update orderList;
	}
	
	public void finish(Database.BatchableContext bc) { 
		// Query the AsyncApexJob object to retrieve the current job's information. 
		AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = :bc.getJobId()]; 
		
		// Send an email to the Apex job's submitter notifying of job completion. 
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
		String[] toAddresses = new String[] { a.CreatedBy.Email }; 
		mail.setToAddresses(toAddresses); 
		mail.setSubject('BatchAnonymizeTicketOrders: ' + a.Status); 
		mail.setPlainTextBody('The BatchAnonymizeTicketOrders job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.'); 
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
	}
}