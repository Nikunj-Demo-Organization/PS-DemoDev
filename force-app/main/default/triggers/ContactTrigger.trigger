trigger ContactTrigger on Contact (after insert, after update, after delete, after undelete) {
    ContactTriggerHandler.updateAccountContactCount(Trigger.new, Trigger.old);
}
