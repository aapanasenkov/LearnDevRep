/**
 * Created by Apanasenkov Aleksandr 20.01.2021.
 */
public with sharing class ContactTableController {

	public class ModelSortParams {
		@AuraEnabled
		public String sortedBy { get; set; }
		@AuraEnabled
		public String sortedDirection { get; set; }
	}

	@AuraEnabled
	public static List<Contact> obtainContacts(ContactTableController.ModelSortParams sortingOptions, String recordLimit, String recordOffset) {
		String sortedBy;
		List<String> queryFields = new List<String>{'Id', 'Name', 'Email', 'Birthdate', 'Account.Name'};
		String query = 'SELECT ' + String.join(queryFields, ',') + ' FROM Contact';

		if (String.isNotBlank(sortingOptions.sortedBy) && String.isNotBlank(sortingOptions.sortedDirection)) {
			query += ' ORDER BY ';
			query += sortingOptions.sortedBy;
			query += ' ' + sortingOptions.sortedDirection + ' NULLS LAST';
		}

		query += ' LIMIT ' + recordLimit + ' OFFSET ' + recordOffset;
		
		return Database.query(query);
	}
	 
	@AuraEnabled
	public static Integer getTotalContacts(){
		return [SELECT Id FROM Contact].size();
	} 
	 
	@AuraEnabled
	public static void deleteContact(Contact contact){
		delete contact;
	} 
}