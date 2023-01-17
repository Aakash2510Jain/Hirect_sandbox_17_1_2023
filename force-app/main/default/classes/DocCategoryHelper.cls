global class DocCategoryHelper {
    
    public boolean displayPopup {get; set;}     
    
    public void closePopup() {        
        displayPopup = false;    
    }     
    public void showPopup() {   
        system.debug('Running');
        displayPopup = true;    
    }
    
    public String blobData {
        get {
            try{
                return EncodingUtil.Base64Encode(docWrapperInstance.blobFile);
            }catch(Exception e){
                return '';
            }
            
        }
    }
    public docWrapper docWrapperInstance{get;set;}
    public DocCategoryHelper() {
        viewPDF();
    }
    
    @RemoteAction
    global static List<DocumentTreeWrapper> getDocuments(String accId) {
        if(String.isBlank(accId))
            return null;
        Map<Id,DocumentTreeWrapper> uiWrapper = new Map<Id,DocumentTreeWrapper>();
        List<Document__c> propAppList=  [Select id,Name from Document__c where  Account__c=:accId];
        String Obj = '';
        if(propAppList.size() > 0){
            for(Document__c appDoc : [SELECT Id, Name,(SELECT Id, Name FROM Documents_Attachments__r) FROM Document__c WHERE Account__c =:accId ORDER BY CreatedDate]) {
                //Handle First level cat Here
                DocumentTreeWrapper appDocWrapper;
                
                appDocWrapper = new DocumentTreeWrapper(appDoc.Id, appDoc.Name); 
                if(!appDoc.Documents_Attachments__r.isEmpty()){
                    for(Documents_Attachment__c appAttachment : appDoc.Documents_Attachments__r) {
                        appDocWrapper.childNodes.add(new DocumentTreeWrapper(appAttachment.Id, appAttachment.Name));
                    }
                }
                
                uiWrapper.put(appDoc.Id, appDocWrapper);
            }
        }
        return uiWrapper.values();
    }
    
    public void viewPDF(){
        String appDocId = Apexpages.currentPage().getParameters().get('attachId');
        system.debug('para::'+appDocId);
        docWrapperInstance = new docWrapper();
        Documents_Attachment__c appDocAttach = new Documents_Attachment__c();
        if(appDocId != null){
            appDocAttach = [SELECT id,Name,Attachement_Id__c FROM Documents_Attachment__c WHERE id =: appDocId];
            if(appDocAttach != null && appDocAttach.Attachement_Id__c != null){
                try{
                    system.debug('appDocAttach.Attachement_Id__c'+appDocAttach.Attachement_Id__c);
                    Attachment att = [select id,name,body,contenttype  from attachment where id =: appDocAttach.Attachement_Id__c limit 1];
                    //if(att.contenttype !=null){
                    docWrapperInstance.contentType = att.contenttype;
                    docWrapperInstance.blobFile = att.body;
                    //}
                }catch(Exception e){
                    System.debug('e.getmshg'+e.getMessage());
                }
            }
        }else{
            //System.debug('e.getmshg'+e.getMessage());
            docWrapperInstance = new docWrapper();
            docWrapperInstance.contentType = 'application/';
            docWrapperInstance.blobFile = blob.valueOf('');
        }
    }
    
    global class DocumentTreeWrapper {
        public String documentID;
        public String documentName;
        public List<DocumentTreeWrapper> childNodes = new List<DocumentTreeWrapper>();
        
        public DocumentTreeWrapper(String documentID, String documentName) {
            this.documentID = documentID;
            this.documentName = documentName;
        }
    }
    
    global class docWrapper{
        public String contentType{get;set;}
        public blob blobFile{get;set;}
    }
    
}