public without sharing class Account_Trigger_Helper{
    public Static boolean runTrigger = true;
    public static void CreateDocumentCategories(List<Account> accList){
        try{
            List<Document_Category__c> docCategory = new List<Document_Category__c>();
            List<Category_Template__c> document_cat_list = new List<Category_Template__c>();
            List<Document__c> DocCatListToBeInserted = new List<Document__c>();
            
            docCategory = [Select Id From Document_Category__c Where Name = 'Basic Doc Category'];
            if(!docCategory.isEmpty()){
                document_cat_list = [Select Id, Name From Category_Template__c Where Document_Category__c = :docCategory[0].Id];
            }

            for (Account acc : accList){
                if(!document_cat_list.isEmpty()){
                    for (Category_Template__c catTemplate : document_cat_list){
                        Document__c doc = new Document__c();
                        doc.Name = catTemplate.Name;
                        doc.Account__c = acc.Id;
                        doc.Category_Template__c = catTemplate.Id;
                        DocCatListToBeInserted.add(doc);
                    }
                }
            }
            if(!DocCatListToBeInserted.isEmpty())
                insert DocCatListToBeInserted;
            
        }catch(exception ex){
            system.debug('Errror-->'+ex.getMessage());
            system.debug('Errror-->'+ex.getCause());
            system.debug('Errror-->'+ex.getLineNumber());
        }
    }
}