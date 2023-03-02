trigger caseAction on Case (After insert) {
    if(trigger.isAfter && trigger.isInsert){
        list<Case> caseList = new List<Case>();
        List<SLA_Configurations__c> sla = new List<SLA_Configurations__c>([SELECT Case_Status__c, Id, Name FROM SLA_Configurations__c Limit 1]);
        for(Case c:trigger.new){
            if(c.Status==sla[0].Case_Status__c)
                caseList.add(c);
        }
        System.debug('caseList Trigger' +caseList);
        caseTriggerHandler.slaTimer(caseList);
    }
}