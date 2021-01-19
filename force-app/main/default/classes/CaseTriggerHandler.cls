public with sharing class CaseTriggerHandler extends TriggerHandler{

    protected override void afterInsert(){
        this.countCasesOnContact((List<Case>)Trigger.new, null);
    }

    protected override void afterUpdate(){
        this.countCasesOnContact((List<Case>)Trigger.new, (Map<Id, Case>)Trigger.oldMap);
    }

    protected override void afterDelete(){
        this.countCasesOnContact((List<Case>)Trigger.old, null);
    }

    protected override void afterUndelete(){
        this.countCasesOnContact((List<Case>)Trigger.new, null);
    }

    private void countCasesOnContact(List<Case> caseList, Map<Id, Case> oldMap) {
        Set<Id> relatedContactIdsSet = this.obtainRelatedContactIds(caseList, oldMap);
        
        if (relatedContactIdsSet.isEmpty()) {
            return;
        }

        List<Contact> existContactsList;
        List<Contact> contactsToUpdateList;

        existContactsList = [SELECT Id, (SELECT Id, IsClosed FROM Cases) FROM Contact WHERE Id IN :relatedContactIdsSet];

        contactsToUpdateList = this.composeListWithContactsToUpdate(existContactsList);

        if (!contactsToUpdateList.isEmpty()){
            update contactsToUpdateList;
        }
    }

    private Set<Id> obtainRelatedContactIds(List<Case> caseList, Map<Id, Case> oldMap) {
        Set<Id> relatedContactIdsSet = new Set<Id>();

        for (Case case_i : caseList) {
            if (String.isNotEmpty(case_i.ContactId)) {
                if (!Trigger.isUpdate) {
                    relatedContactIdsSet.add(case_i.ContactId);
                } else if (Trigger.isUpdate && (case_i.IsClosed != oldMap.get(case_i.Id).IsClosed || case_i.ContactId != oldMap.get(case_i.Id).ContactId)) {
                    relatedContactIdsSet.add(case_i.ContactId);
                    if (case_i.ContactId != oldMap.get(case_i.Id).ContactId && oldMap.get(case_i.Id).ContactId != null) {
                        relatedContactIdsSet.add(oldMap.get(case_i.Id).ContactId);
                    }
                }
            }
        }

        return relatedContactIdsSet;
    }

    private List<Contact> composeListWithContactsToUpdate(List<Contact> contacts) {
        List<Contact> contactsToUpdateList = new List<Contact>();

        for (Contact contact_i : contacts) {
            Contact contact = new Contact(Id = contact_i.Id);
            List<Case> openCases = new List<Case>();
            List<Case> closeCases = new List<Case>();

            for (Case case_i : contact_i.Cases) {
                if (!case_i.IsClosed) {
                    openCases.add(case_i);
                } else {
                    closeCases.add(case_i);
                }
            }

            contact.Open_Cases__c = openCases.size();
            contact.Close_Cases__c = closeCases.size();
            contactsToUpdateList.add(contact);
        }

        return contactsToUpdateList;
    }
}
