/**
 * Created by Apanasenkov Aleksandr 21.01.2021.
 */
@isTest
public with sharing class CountCasesPerContactBatchTest {
	@TestSetup
	static void setupData(){

		Contact contact = new Contact(Phone = '1111111111', LastName = 'Test1');
		
		insert contact;

		List<Case> caseList = new List<Case>();
		caseList.add(new Case(Origin = 'Phone', Status = 'New', ContactId = contact.Id));
		caseList.add(new Case(Origin = 'Phone', Status = 'Closed', ContactId = contact.Id));

		insert caseList;
	}

	@isTest
	static void countCasesPerContactBatchTest() {
		Test.startTest();
		CountCasesPerContactBatch batch = new CountCasesPerContactBatch();
		Database.executeBatch(batch, 1);
		Test.stopTest();

		Contact contact = [SELECT Id, Open_Cases__c, Close_Cases__c FROM Contact LIMIT 1];
		
		System.assertEquals(contact.Open_Cases__c, 1);
		System.assertEquals(contact.Close_Cases__c, 1);
	}
}
