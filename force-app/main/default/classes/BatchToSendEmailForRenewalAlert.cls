public class BatchToSendEmailForRenewalAlert implements Database.Batchable<sObject>, Database.Stateful{
    //Schedule for daily
    public Database.QueryLocator start(Database.BatchableContext bc){
        Date daysAfter = date.today().addDays(7);
        String QueryString = 'SELECT AccountId,CreatedDate,Id,Account_Email__c,Name,OwnerId FROM Opportunity Where Renewable_Date__c =: daysAfter';
        return Database.getQueryLocator(QueryString);
    }

    public void execute(Database.BatchableContext bc, List<opportunity> OppList){

        if (!OppList.isEmpty()){
            EmailIUtility.SendEmailBeforeRenewalDate(OppList, Constants.OPPORTUNITY_RENEWAL_EMAIL);
        }
    }

    public void finish(Database.BatchableContext bc){
    }

}