trigger CaseTrigger on Case (before insert, after update, before update) {
    
    if(trigger.isupdate && trigger.isbefore){
        CaseTriggerHandler.CaseAgeTime(trigger.oldmap, trigger.newmap);
    }

}