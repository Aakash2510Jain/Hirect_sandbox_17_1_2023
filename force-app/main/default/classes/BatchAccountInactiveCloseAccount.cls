public without sharing class BatchAccountInactiveCloseAccount implements Database.Batchable<sObject>, Database.Stateful{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        Date nowDate = System.today().addDays(Integer.valueOf(OrgConfigUtility.orgConfig.Inactive_After_Days__c));
        String Query = 'SELECT Id,Status__c, Inactive_Since__c FROM Account Where Status__c = \'Inactive\' AND  Inactive_Since__c <: nowDate';
        return Database.getQueryLocator(Query);
    }

    public void Execute(Database.BatchableContext bc, List<Account> accList){
        System.debug('accList---->' + accList);
        List<Account> accountListToBeUpdated = new List<Account>();
        Set<Id> accIds = new Set<Id>();
        List<Task> taskListToBeInserted = new List<task>();
        if (!accList.isEmpty()){
            for (Account acc : accList){

                if (acc.Status__c == 'Inactive'){
                    Account accRec = new Account();
                    accRec.Id = acc.Id;
                    accRec.Status__c = 'Lost';
                    accountListToBeUpdated.add(accRec);

                    Task taskRecord = new Task();
                    taskRecord.Subject = 'Account is marked LOST since it is in InActive stage';
                    taskRecord.Status = 'Open';
                    taskRecord.Priority = 'Normal';
                    taskRecord.WhatID = accRec.id;
                    taskRecord.OwnerId = accRec.OwnerId;
                    taskListToBeInserted.add(taskRecord);
                    accIds.add(acc.Id);
                }
            }
            if (!taskListToBeInserted.isEmpty()){
                insert taskListToBeInserted;
            }
            if (!accountListToBeUpdated.isEmpty()){
                update accountListToBeUpdated;
                EmailIUtility.sendEmail(accIds, Constants.DEAD_EMAIL_TEMPLATE, 'DEAD');
            }


        }
    }

    public void Finish(Database.BatchableContext bc){
        System.debug('Batch Run Successfully');
    }

}