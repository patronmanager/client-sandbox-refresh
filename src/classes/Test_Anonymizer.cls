@IsTest
class Test_Anonymizer {
	static testMethod void testGetAnonymizedEmail() {
		String email = 'test@testing.com';
		System.assertEquals('prefix+test@mydomain.com', Anonymizer.getAnonymizedEmail(email, 'prefix', 'mydomain.com'));
		System.assertEquals('test@mydomain.com', Anonymizer.getAnonymizedEmail(email, null, 'mydomain.com'));
	}
	
	static testMethod void testAnonymizeContacts() {
		Contact c = new Contact(FirstName = 'Test', LastName = 'Tester', Email = 'test.tester@testing.com');
		insert c;
		System.Test.startTest();
		Database.executeBatch(new BatchAnonymizeContacts('myprefix', 'mydomain.com'));
		System.Test.stopTest();
		c = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Id = :c.Id];
		System.assertEquals('myprefix+test.tester@mydomain.com', c.Email);
	}
	
	static testMethod void testAnonymizeTicketOrders() {
		PatronTicket__PatronTicketSettings__c settings = new PatronTicket__PatronTicketSettings__c();
		insert settings;
		PatronTicket__TicketOrder__c ticketOrder = new PatronTicket__TicketOrder__c(
			PatronTicket__FirstName__c = 'Test', PatronTicket__LastName__c = 'Tester', 
			PatronTicket__Email__c = 'test.tester@testing.com', PatronTicket__OrderStatus__c = 'Draft'
		);
		insert ticketOrder;
		System.Test.startTest();
		Database.executeBatch(new BatchAnonymizeTicketOrders('myprefix', 'mydomain.com'));
		System.Test.stopTest();
		ticketOrder = [SELECT Id, PatronTicket__FirstName__c, PatronTicket__LastName__c, PatronTicket__Email__c FROM PatronTicket__TicketOrder__c WHERE Id = :ticketOrder.Id];
		System.assertEquals('myprefix+test.tester@mydomain.com', ticketOrder.PatronTicket__Email__c);
	}
}