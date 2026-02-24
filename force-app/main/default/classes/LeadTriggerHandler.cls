public with sharing class LeadTriggerHandler {

    public static void applyRankingRules(List<Lead> leads) {
        List<Lead_Ranking_Rule__mdt> rules = [
            SELECT Industry__c, Min_Annual_Revenue__c, Max_Annual_Revenue__c, Priority_Rating__c
            FROM Lead_Ranking_Rule__mdt
        ];

        if (rules.isEmpty()) {
            return;
        }

        for (Lead lead : leads) {
            for (Lead_Ranking_Rule__mdt rule : rules) {
                Boolean revenueMatches = lead.AnnualRevenue != null
                    && lead.AnnualRevenue >= rule.Min_Annual_Revenue__c
                    && lead.AnnualRevenue <= rule.Max_Annual_Revenue__c;

                Boolean industryMatches = String.isBlank(rule.Industry__c)
                    || rule.Industry__c == lead.Industry;

                if (revenueMatches && industryMatches) {
                    lead.Rating = rule.Priority_Rating__c;
                    break;
                }
            }
        }
    }
}
