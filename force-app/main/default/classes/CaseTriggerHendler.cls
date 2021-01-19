public with sharing class CaseTriggerHendler {
    public static void afterInsertHandler(List<Case> newCases) {
        countCasesOnContact(newCases);
    }

    public static void afterUpdateHandler(Map<Id, Case> oldCases, Map<Id, Case> newCases) {
        List<Case> modifiedCases = new List<Case>();

        for (Id caseId : newCases.keySet()) {
            Case newCase = newCases.get(caseId);
            Case oldCase = oldCases.get(caseId);
            if (newCase.IsClosed != oldCase.IsClosed) {
                modifiedCases.add(newCase);
            }
        }

        if (!modifiedCases.isEmpty()){
            countCasesOnContact(modifiedCases);
        }
    }

    public static void afterDeleteHandler(List<Case> oldCases) {
        countCasesOnContact(oldCases);
    }

    public static void countCasesOnContact(List<Case> cases) {
        List<Id> relatedContactIdsLst = new List<Id>();

        for (Case cs : cases) {
            relatedContactIdsLst.add(cs.ContactId);
        }

        List<Contact> contacts = [SELECT Id, (SELECT Id, IsClosed FROM Cases) FROM Contact WHERE Id IN :relatedContactIdsLst];

        List<Contact> contactsToUpdate = new List<Contact>();

        for (Contact ct : contacts) {
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
            contactsToUpdate.add(contact);
        }

        if (!contactsToUpdate.isEmpty()){
            update contactsToUpdate;
        }
    }
    
}
