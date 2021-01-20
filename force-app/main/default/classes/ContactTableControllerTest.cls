/**
 * Created by Apanasenkov Aleksandr 20.01.2021.
 */
@IsTest
public with sharing class ContactTableControllerTest {
    @TestSetup
    static void setupData(){
        
        List<Contact> contactList = new List<Contact>();
        contactList.add(new Contact(Phone = '1111111111', LastName = 'Test1'));
        contactList.add(new Contact(Phone = '2222222222', LastName = 'Test2'));
        
        insert contactList;
    }

    @IsTest
    static void obtainContactsTest() {
        ContactTableController.ModelSortParams params = new ContactTableController.ModelSortParams();
        params.sortedBy = 'Birthdate';
        params.sortedDirection = 'asc';

        List<Contact> contactList = ContactTableController.obtainContacts(params, '2', '0');

        System.assertEquals(contactList.size(), 2);
    }

    @IsTest
    static void getTotalContactsTest() {
        System.assertEquals(ContactTableController.getTotalContacts(), 2);
    }

    @IsTest
    static void deleteContactTest() {
        List<Contact> contactList = [SELECT Id FROM Contact LIMIT 2];
        ContactTableController.deleteContact(contactList.get(0));
        
        contactList = [SELECT Id FROM Contact];
        System.assertEquals(contactList.size(), 1);
    }
}
