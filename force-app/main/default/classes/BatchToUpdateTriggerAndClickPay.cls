public class BatchToUpdateTriggerAndClickPay implements Database.Batchable<SObject>{
    public Database.QueryLocator Start(Database.BatchableContext bc){
        String Query = 'SELECT Id,Trigger_0day__c,Trigger_Previous_Days__c,Clickpay_0day__c,Click_Previous_Day__c,Trigger_Exclusive_Job_0_Day__c,Trigger_Exclusive_Job_Previous_Day__c From Lead where Trigger_0day__c > 0  or Clickpay_0day__c > 0 or Trigger_Exclusive_Job_0_Day__c > 0';
        system.debug('Query------' + Query);
        return Database.getQueryLocator(Query);
    }
    public void execute(Database.BatchableContext bc, List<lead> ldList){
        List<Lead> leadListToUpdate = new List<Lead>();
        
        if(!ldList.isEmpty()){
            for(Lead leadRec : ldList){
                Lead leadRecToUpdate = new Lead();
                leadRecToUpdate.Id = leadRec.Id;
                if(leadRec.Trigger_0day__c == null)
                    leadRec.Trigger_0day__c =0;
                if(leadRec.Trigger_Previous_Days__c == null)
                    leadRec.Trigger_Previous_Days__c =0;
                leadRecToUpdate.Trigger_Previous_Days__c = leadRec.Trigger_0day__c + leadRec.Trigger_Previous_Days__c;
                
                if(leadRec.Trigger_Exclusive_Job_0_Day__c == null)
                    leadRec.Trigger_Exclusive_Job_0_Day__c =0;
                if(leadRec.Trigger_Exclusive_Job_Previous_Day__c == null)
                    leadRec.Trigger_Exclusive_Job_Previous_Day__c =0;
                leadRecToUpdate.Trigger_Exclusive_Job_Previous_Day__c = leadRec.Trigger_Exclusive_Job_0_Day__c + leadRec.Trigger_Exclusive_Job_Previous_Day__c;
                
                if(leadRec.Clickpay_0day__c == null)
                    leadRec.Clickpay_0day__c =0;
                if(leadRec.Click_Previous_Day__c == null)
                    leadRec.Click_Previous_Day__c =0;
                leadRecToUpdate.Click_Previous_Day__c = leadRec.Clickpay_0day__c + leadRec.Click_Previous_Day__c;
                
                leadRecToUpdate.Trigger_0day__c = 0;
                leadRecToUpdate.Clickpay_0day__c = 0;
                leadRecToUpdate.Trigger_Exclusive_Job_0_Day__c = 0;
                leadListToUpdate.add(leadRecToUpdate);
            }
            if(!leadListToUpdate.isEmpty()){
                update leadListToUpdate;
            }
        }   
    }
    
    public void Finish(Database.BatchableContext bc){
    }
    
}