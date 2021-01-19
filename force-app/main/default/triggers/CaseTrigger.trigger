trigger CaseTrigger on Case (before insert, after insert, before update, after update, before delete, after delete) {
    if (Trigger.isAfter && Trigger.isInsert) {
		CaseTriggerHendler.afterInsertHandler(Trigger.new);
	} else if (Trigger.isAfter && Trigger.isUpdate) {
		CaseTriggerHendler.afterUpdateHandler(Trigger.oldMap, Trigger.newMap);
	} else if (Trigger.isAfter && Trigger.isDelete) {
		CaseTriggerHendler.afterDeleteHandler(Trigger.old);
	}
}