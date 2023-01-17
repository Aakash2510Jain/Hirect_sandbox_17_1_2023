public class Attachement_Trigger_Helper {
    static Attachement_Trigger_Helper handlerInstance;
    public static Attachement_Trigger_Helper getInstance() {
        if(handlerInstance == null) 
            handlerInstance = new Attachement_Trigger_Helper();
        return handlerInstance;
    }
    public void HandleAttachements(List<Attachment> AttList){
        try{
            //system.debug('AttList'+AttList);
            Boolean isProposal = false;
            List<id> parentIds = new List<Id>();
            List<Documents_Attachment__c> DocAttList = new List<Documents_Attachment__c>();
            List<Document__c> propList = new List<Document__c>();
            
            if(!AttList.isEmpty()){
                for(Attachment att : AttList){
                    parentIds.add(att.parentId);
                } 
                if(!parentIds.isEmpty()){
                    propList=  [Select id from Document__c where id in : parentIds]; 
                    if(!propList.isEmpty()){
                        for(Document__c doc: propList){
                            doc.Status__c = 'Uploaded';
                        } 
                        if(propList.size() > 0){
                            isProposal = true;
                        }
                    }
                }   
                for(Attachment att : AttList){
                    Documents_Attachment__c da = new Documents_Attachment__c();
                    da.Attachement_Id__c  = att.Id;
                    da.name = att.Name;
                    if(isProposal == true){
                        da.Document__c =  att.ParentId;
                        DocAttList.add(da);
                    }
                }
                if(DocAttList.size() > 0){
                    insert DocAttList;    
                    update propList;
                }
            }
        }catch(exception ex ){
            system.debug('Error==>'+ex.getMessage());
            system.debug('Error==>@@'+ex.getLineNumber());
        }
    }
}