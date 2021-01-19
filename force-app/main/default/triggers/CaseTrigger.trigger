trigger CaseTrigger on Case (before update, before delete, after insert, after update, after delete, after undelete) {
    new CaseTriggerHandler().run();
}