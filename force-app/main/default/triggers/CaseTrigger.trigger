
/**
 * Created by Apanasenkov Aleksandr 19.01.2021.
 */
trigger CaseTrigger on Case (before update, before delete, after insert, after update, after delete, after undelete) {
    new CaseTriggerHandler().run();
}