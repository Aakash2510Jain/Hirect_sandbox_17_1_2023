public class BatchToSendMailOnOppCreation implements Database.Batchable<sObject>, Database.Stateful{
    // will be schedule to run daily
    public Database.QueryLocator start(Database.BatchableContext bc){

        String QueryString = 'SELECT AccountId,CreatedDate,Id,StageName FROM Opportunity Where CreatedDate = today';
        return Database.getQueryLocator(QueryString);
    }

    public void execute(Database.BatchableContext bc, List<opportunity> OppList){

        Set<Id> IdSetForEmail = new Set<Id>();
        for (Opportunity opp : OppList){
            IdSetForEmail.add(opp.Id);
        }
        system.debug('IdSetForEmail :: ' + IdSetForEmail);
        if (!IdSetForEmail.isEmpty()){
            EmailIUtility.SendEmailOnOppCreation(IdSetForEmail, Constants.OPPORTUNITY_WELCOME_EMAIL);
        }
    }

    public void finish(Database.BatchableContext bc){
    }

}