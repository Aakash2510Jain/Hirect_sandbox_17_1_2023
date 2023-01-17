@isTest
public class InvoiceTriggerTestClass {
    
    @isTest(SeeAllData=true)
    public static void testInvoice(){
        Invoice__c inv = new Invoice__c();
        inv.CGST__c = true;
        insert inv;
        inv.IGST__c = true;
        update inv;
    }
    
    @isTest
    public static void insertUserTrackingRec(){
        User_Tracking__c userTrackRec = new User_Tracking__c();
        userTrackRec.Checkin_Datetime__c = system.now();
        insert userTrackRec;
    }
    //Lead
    @isTest
    public static void insertLeadRec(){
        Lead leadRec = new Lead();
        leadRec.LAstName = 'Abc';
        leadRec.Company = 'Abc';
        insert leadRec;
        Attachment attachmentRec = new Attachment();
        attachmentRec.Name = 'Abc';
        attachmentRec.Body = blob.valueOf('asdsffsf');
        attachmentRec.ParentId = leadRec.Id;
        insert attachmentRec;
    }
    
    //Account
    @isTest
    public static void insertAccountRec(){
        Account accountRec = new Account();
        accountRec.Name = 'Abc';
        insert accountRec;
    }
    //TaskTrigger
    @isTest
    public static void insertTaskRec(){
        Task taskRec = new Task();
        taskRec.Subject = 'Abc';
        insert taskRec;
    }
    //OpportunityTrigger
    @isTest(SeeAllData=true)
    public static void insertOpportunityRec(){
        Opportunity OpportunityRec = new Opportunity();
        OpportunityRec.Description = 'Abc';
        OpportunityRec.Name = 'sdfghjk';
        OpportunityRec.CloseDate = system.today();
        OpportunityRec.StageName = 'Qualification';
        insert OpportunityRec;
        OpportunityLineItem OpportutnityLineItemRec = new OpportunityLineItem();
        OpportutnityLineItemRec.Description = 'Abc';
        OpportutnityLineItemRec.OpportunityId = OpportunityRec.Id;
        OpportutnityLineItemRec.Quantity = 2;
        OpportutnityLineItemRec.TotalPrice = 100;
        OpportutnityLineItemRec.PricebookEntryId = [Select Id from PricebookEntry where isActive = true limit 1].ID;
        insert OpportutnityLineItemRec;
    }
}