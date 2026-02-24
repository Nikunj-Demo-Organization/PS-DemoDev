trigger LeadTrigger on Lead (before insert, before update) {
    LeadTriggerHandler.applyRankingRules(Trigger.new);
}
