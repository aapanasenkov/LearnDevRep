public with sharing class CaseTriggerHandler extends TriggerHandler{

    protected override void afterInsert(){
        this.countCasesOnContact((List<Case>)Trigger.new);
    }

    protected override void afterUpdate(){
        this.countCasesOnContact((List<Case>)Trigger.new);
    }

    protected override void afterDelete(){
        this.countCasesOnContact((List<Case>)Trigger.old);
    }

    protected override void afterUndelete(){
        this.countCasesOnContact((List<Case>)Trigger.new);
    }

    private void countCasesOnContact(List<Case> newCases) {
        Set<Id> relatedContactIdsSet = new Set<Id>();
        List<Contact> existContactsList;
        List<Contact> contactsToUpdateList = new List<Contact>();

        for (Case cs : newCases) {
            if (String.isNotEmpty(cs.ContactId)) {
                relatedContactIdsSet.add(cs.ContactId);
            }
        }

        if (!relatedContactIdsSet.isEmpty()) {
            existContactsList = [SELECT Id, (SELECT Id, IsClosed FROM Cases) FROM Contact WHERE Id IN :relatedContactIdsSet];

            for (Contact ct : existContactsList) {
                Contact contact = new Contact(Id = ct.Id);
                List<Case> openCases = new List<Case>();
                List<Case> closeCases = new List<Case>();
    
                for (Case cs : ct.Cases) {
                    if (!cs.IsClosed) {
                        openCases.add(cs);
                    } else {
                        closeCases.add(cs);
                    }
                }
    
                contact.Open_Cases__c = openCases.size();
                contact.Close_Cases__c = closeCases.size();
                contactsToUpdateList.add(contact);
            }
    
            if (!contactsToUpdateList.isEmpty()){
                update contactsToUpdateList;
            }
        }
    }
}
