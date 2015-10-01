public with sharing class Anonymizer {

	public static void anonymize(String prefix, String domain) {
		System.assert(!String.isBlank(domain), 'You must specify an email domain for anonymizing Contact and Ticket Order email addresses.');
		Database.executeBatch(new BatchAnonymizeContacts(prefix, domain), 100); 
		Database.executeBatch(new BatchAnonymizeTicketOrders(prefix, domain), 100); 
	}
	
	public static String getAnonymizedEmail(String email, String prefix, String domain) {
		System.assert(!String.isBlank(domain), 'You must specify an email domain.');
		// Pre-pend the prefix if specified
		String anonymizedEmail = email;
		if (!String.isBlank(prefix)) {
			anonymizedEmail = prefix + '+' + anonymizedEmail;
		}
		anonymizedEmail = anonymizedEmail.substring(0, anonymizedEmail.indexOf('@')) + '@' + domain; 
		return anonymizedEmail;
	}
}