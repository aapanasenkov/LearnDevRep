/**
 * Created by Apanasenkov Aleksandr 19.01.2021.
 */
@IsTest
public with sharing class CaseTriggerHandlerTest {
    @TestSetup
    static void setupData(){
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(Phone = '1111111111', LastName = 'Test1'));
        contactList.add(new Contact(Phone = '2222222222', LastName = 'Test2'));
        
        insert contactList;

        List<Case> caseList = new List<Case>();
        caseList.add(new Case(Origin = 'Phone', Status = 'New', ContactId = contactList.get(0).Id));
        
        insert caseList;
    }

    @IsTest
    static void isertCaseWithNewStatusTest() {
        Contact contact = [SELECT Id, Phone, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id NOT IN (SELECT ContactId FROM Case) LIMIT 1];
        System.debug(contact.Phone);

        Case newCase = new Case(Origin = 'Phone', Status = 'New', ContactId = contact.Id);
        insert newCase;

        Contact updatedContact = [SELECT Id, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id = :contact.Id LIMIT 1];

        System.assertEquals(updatedContact.Open_Cases__c, 1);
    }

    @IsTest
    static void isertCaseWithClosedStatusTest() {
        Contact contact = [SELECT Id, Phone, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id NOT IN (SELECT ContactId FROM Case) LIMIT 1];
        System.debug(contact.Phone);

        Case newCase = new Case(Origin = 'Phone', Status = 'Closed', ContactId = contact.Id);
        insert newCase;

        Contact updatedContact = [SELECT Id, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id = :contact.Id LIMIT 1];

        System.assertEquals(updatedContact.Close_Cases__c, 1);
    }

    @IsTest
    static void deleteCaseTest() {
        Contact contact = [SELECT Id, Open_Cases__c, Close_Cases__c, Phone FROM Contact WHERE Id IN (SELECT ContactId FROM Case) LIMIT 1];
        System.assertEquals(contact.Open_Cases__c, 1);

        delete [SELECT Id FROM Case WHERE ContactId = :contact.Id];

        Contact updatedContact = [SELECT Id, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id = :contact.Id LIMIT 1];
        System.assertEquals(updatedContact.Open_Cases__c, 0);
    }

    @IsTest
    static void undeleteCaseTest() {
        Contact contact = [SELECT Id, Open_Cases__c, Close_Cases__c, Phone FROM Contact WHERE Id IN (SELECT ContactId FROM Case) LIMIT 1];
        System.assertEquals(contact.Open_Cases__c, 1);

        Case cs = [SELECT Id FROM Case WHERE ContactId = :contact.Id];
        delete cs;

        Contact updatedContact = [SELECT Id, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id = :contact.Id LIMIT 1];
        System.assertEquals(updatedContact.Open_Cases__c, 0);

        undelete cs;
        updatedContact = [SELECT Id, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id = :contact.Id LIMIT 1];
        System.assertEquals(updatedContact.Open_Cases__c, 1);

    }

    @IsTest
    static void reassignCaseToAnotherContactTest() {
        Contact contactWithCase = [SELECT Id, Open_Cases__c, Close_Cases__c, Phone FROM Contact WHERE Id IN (SELECT ContactId FROM Case) LIMIT 1];
        Contact contactWithoutCase = [SELECT Id, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id NOT IN (SELECT ContactId FROM Case) LIMIT 1];
        System.assertEquals(contactWithCase.Open_Cases__c, 1);
        System.assertEquals(contactWithoutCase.Open_Cases__c, null);

        Case cs = [SELECT Id, ContactId FROM Case WHERE ContactId = :contactWithCase.Id];
        cs.ContactId = contactWithoutCase.Id;
        update cs;

        Contact updatedContactWithCase = [SELECT Id, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id = :contactWithoutCase.Id LIMIT 1];
        System.assertEquals(updatedContactWithCase.Open_Cases__c, 1);

        Contact updatedContactWithoutCase = [SELECT Id, Open_Cases__c, Close_Cases__c FROM Contact WHERE Id = :contactWithCase.Id LIMIT 1];
        System.assertEquals(updatedContactWithoutCase.Open_Cases__c, 0);
    }
}
