public with sharing class BatchOpportunityRenewableDate implements Database.Batchable<Sobject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        Date nowDate = System.today();
        nowDate = nowDate.addDays(Integer.valueOf(OrgConfigUtility.orgConfig.Renewal_After_Days__c));
        String Query = 'SELECT AccountId,CreatedDate,Id,Account_Email__c,Renewable_Date__c,Name,OwnerId FROM Opportunity Where Renewable_Date__c =: nowDate';
        return Database.getQueryLocator(Query);
    }

    public void Execute(Database.BatchableContext bc, List<Opportunity> oppList){
        if (!oppList.isEmpty()){
            Set<Id> opportutnityIds = new Set<Id>();
            List<Task> taskListToBeInserted = new List<task>();

            Date todayDate = System.today();
            todayDate = todayDate.addDays(7);

            for (Opportunity opp : oppList){
                System.debug('The OppList--->' + opp);
                if (opp.Renewable_Date__c != null && opp.Renewable_Date__c == todayDate){
                    opportutnityIds.add(opp.Id);

                    Task taskrec = new Task();
                    taskrec.Subject = 'Followup with Client for Opportunity Renewable';
                    taskRec.Priority = 'Normal';
                    taskrec.Status = 'Open';
                    taskrec.OwnerId = opp.OwnerId;
                    taskrec.WhatId = opp.Id;
                    taskrec.ActivityDate = opp.Renewable_Date__c;
                    taskListToBeInserted.add(taskrec);
                }
            }
            //create Task for owner
            if (!taskListToBeInserted.isEmpty()){
                insert taskListToBeInserted;
            }
            //send Email
            if (!opportutnityIds.isEmpty()){
                EmailIUtility.sendEmail(opportutnityIds, Constants.RENEWAL_EMAIL_TEMPLATE, 'RENEWAL');
            }

        }
    }

    public void Finish(Database.BatchableContext bc){
    }

}