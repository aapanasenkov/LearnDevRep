/**
 * Created by Apanasenkov Aleksandr 21.01.2021.
 */
public class CountCasesPerContactBatch implements Database.Batchable<sObject> {

    public Database.QueryLocator start (Database.BatchableContext bc) {
		return Database.getQueryLocator([SELECT Id, Open_Cases__c, Close_Cases__c, (SELECT Id, IsClosed FROM Cases) FROM Contact WHERE Id IN (SELECT ContactId FROM Case)]);
	}

	public void execute (Database.BatchableContext bc, List<Contact> scope) {
        List<Contact> contactsToUpdateList = new List<Contact>();
        
        for (Contact contact_i : scope) {
            List<Case> openCases = new List<Case>();
            List<Case> closeCases = new List<Case>();

            for (Case case_i : contact_i.Cases) {
                if (!case_i.IsClosed) {
                    openCases.add(case_i);
                } else {
                    closeCases.add(case_i);
                }
            }

            contact_i.Open_Cases__c = openCases.size();
            contact_i.Close_Cases__c = closeCases.size();
            contactsToUpdateList.add(contact_i);
        }

        update contactsToUpdateList;
	}

	public void finish (Database.BatchableContext bc) {
		
	}
}
