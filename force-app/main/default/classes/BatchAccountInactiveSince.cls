public with sharing class BatchAccountInactiveSince implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        Date nowDate = System.today().addDays(Integer.valueOf(OrgConfigUtility.orgConfig.Inactive_After_Days__c));
        String Query = 'SELECT Id,Status__c, Inactive_Since__c,OwnerId FROM Account Where Status__c != \'Inactive\' AND  Inactive_Since__c <:nowDate';
        return Database.getQueryLocator(Query);
    }
    
    public void Execute(Database.BatchableContext bc, List<Account> accList){
        try{
            System.debug('accList---->' + accList);
            Set<Id> accIds = new Set<Id>();
            List<Account> accountListToBeUpdated = new List<Account>();
            List<Task> taskListToBeInserted = new List<task>();
            if (!accList.isEmpty()){
                
                for (Account acc : accList){
                    
                    if (acc.Status__c != 'Inactive'){
                        Account accRec = new Account();
                        accRec.id = acc.Id;
                        accRec.Status__c = 'Inactive';
                        accountListToBeUpdated.add(accRec);
                        
                        Task taskRecord = new Task();
                        taskRecord.Subject = 'Followup with client for Renewal';
                        taskRecord.Status = 'Open';
                        taskRecord.Priority = 'Normal';
                        taskRecord.WhatId = acc.id;
                        taskRecord.OwnerId = acc.OwnerId;
                        taskListToBeInserted.add(taskRecord);
                        accIds.add(acc.Id);
                    }
                }
                
                if (!taskListToBeInserted.isEmpty()){
                    insert taskListToBeInserted;
                }
                if (!accountListToBeUpdated.isEmpty()){
                    update accountListToBeUpdated;
                }
                if(!accIds.isEmpty())
                    EmailIUtility.sendEmail(accIds, Constants.INACTIVE_EMAIL_TEMPLATE, 'INACTIVE');
                
            }
        }catch(exception ex){
            system.debug('Error-->'+ex.getMessage());
            system.debug('Error->'+ex.getLineNumber());
            system.debug('Error-->'+ex.getStackTraceString());
        }
    }
    
    public void Finish(Database.BatchableContext bc){
    }
    
}