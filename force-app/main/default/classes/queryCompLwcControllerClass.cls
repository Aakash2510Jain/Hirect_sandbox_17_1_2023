public with sharing class queryCompLwcControllerClass {
    
    @AuraEnabled(cacheable=true)
    public static  list<String> getallObjectName( String SobjectApiName){
        list<string> FieldValues = new list<String>();
        map<String,String> fieldApiNameByLabelName = new map<String,String>();
        try {
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            return FieldValues;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    @AuraEnabled(cacheable=true)
    public static List<objectSelectionWrapper> getFieldNamesByObject(String ObjName){
        List<objectSelectionWrapper> objectSelectionWrapperList = new  List<objectSelectionWrapper>();
        Map<String, Schema.SObjectField> M_Objects_Schema_Field = Schema.getGlobalDescribe().get(ObjName).getDescribe().fields.getMap();
        //this map will contain api and label name
        Map<String,String> fieldApiNameByLabelName = new map<String,String>();
        //This map will contain Field api name by their type
        Map<String,String> fieldTypeByApiName = new map<String,String>();
        //This map will contain Field api name by their type
        Map<String,list<String>> customSettingNamebyValue = new  Map<String,list<String>>();
        
        for( String a_Field_Name : M_Objects_Schema_Field.keySet() ) {
            Schema.DescribeFieldResult a_Field_Description = M_Objects_Schema_Field.get( a_Field_Name ).getDescribe();
            fieldApiNameByLabelName.put(a_Field_Description.getLabel(),a_Field_Description.getName());
        }
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(ObjName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        
        for (String fieldName: fieldMap.keySet()) {
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            //system.debug('fielddataType '+fielddataType);
            fieldTypeByApiName.put(fieldName, String.valueOf(fielddataType));
        } 
        
        list<Matching_Type_Operator__c> fieldName =[SELECT Field_Name__c,Id,Name FROM Matching_Type_Operator__c];
        
        for(Matching_Type_Operator__c lv : fieldName  ) {
            customSettingNamebyValue.put(lv.Name,lv.Field_Name__c.split(','));
        }
        
        objectSelectionWrapper wrapperInstance = new objectSelectionWrapper();
        wrapperInstance.fieldLabelNameByApiName = fieldApiNameByLabelName;
        wrapperInstance.fieldTypeByApiName = fieldTypeByApiName;
        wrapperInstance.customSettingData = customSettingNamebyValue;
        objectSelectionWrapperList.add(wrapperInstance); 
        system.debug('objectSelectionWrapperList'+objectSelectionWrapperList);
        system.debug('customSettingNamebyValue'+customSettingNamebyValue);
        
        return objectSelectionWrapperList;
    }
    
    @AuraEnabled(cacheable=true)
    public Static  Map<String,list<String>> customStting(){
        Map<String,list<String>> custonSeetingNamebyValue = new  Map<String,list<String>>();
        
        list<String> opratorValues = new list<String>();
        //list<String> nameValue = new list<String>();
        String Names ;
        list<Matching_Type_Operator__c> fieldName = new  list<Matching_Type_Operator__c>();
        fieldName =[SELECT Field_Name__c,Id,Name FROM Matching_Type_Operator__c];
        system.debug('Matching_Type_Operator__c :::::'+ fieldName);
        for(Matching_Type_Operator__c lv : fieldName  ) {
            
            custonSeetingNamebyValue.put(lv.Name,lv.Field_Name__c.split(','));
            
        }
        
        system.debug('custonSeetingNamebyValue: outofLoop::::'+custonSeetingNamebyValue);
        String alpha = 'split,this,sentence'; 
        List<String> lstAlpha = alpha.split('\\|');
        system.debug('lstAlpha::::' +lstAlpha);
        system.debug('custonSeetingNamebyValue::::'+custonSeetingNamebyValue);
        return custonSeetingNamebyValue;
        
        
    }
    
    @AuraEnabled
    public static List<String> getallObject(){
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Set<String> standardObjects = new Set<String>();
        Set<String> customObjects = new Set<String>();
        for(Schema.SObjectType d : gd.values())
        {
            Schema.DescribeSObjectResult ds = d.getDescribe();
            if(!ds.isCreateable())
                continue;
            if(ds.isCustom() == false && ds.getRecordTypeInfos().size() > 0)
                standardObjects.add(ds.getName());
            else if(ds.isCustom())
                customObjects.add(ds.getName());
        }
        List<String> sortedNames = new List<String>(customObjects);
        sortedNames.sort();
        for(String name : sortedNames)
            System.debug('Custom object: ' + name);
        sortedNames = new List<String>(standardObjects);
        sortedNames.sort();
        for(String name : sortedNames)
            System.debug('Standard object: ' + name);
        return sortedNames;
        
    } 
    
    // wrapper class with @AuraEnabled and {get;set;} properties 
    public class objectSelectionWrapper{
        @AuraEnabled 
        public map<String,String> fieldLabelNameByApiName{get;set;}
        
        @AuraEnabled 
        public map<String,String> fieldTypeByApiName{get;set;}
        
        @AuraEnabled 
        public  Map<String,list<String>> customSettingData{get;set;}
        
    }
    
    public class filterCriteria{
        @AuraEnabled
        public String selectedField{get;set;}
        
        @AuraEnabled
        public String selectedOpetor{get;set;} 
        
        @AuraEnabled
        public String inputValue{get;set;}
        
        //multiple feild list "multiSelectefFiledList":["Email","Department","Birthdate","CreatedDate","Contact_Role__c","Languages__c"],
        @AuraEnabled
        public list<String> multiSelectefFiledList{get;set;}
        
        
    }
    
    @AuraEnabled
    public static  DynamicLWCDataTableController.DataTableResponse queryFromUI( List<filterCriteria> FilteredCriterias,String ObjectName){
        System.debug(FilteredCriterias);
        List<String> FieldNames  =new List<String>();
        String allfieldNames = '';
        String allOperators= '';
        String allInputValue='';
        String withOutCommaaFeildNames='';
        String lstfeildvalueWithoutAnd='';
        String feidForWhereClause='';
        String multiSelectefFiled='';
        for(filterCriteria fc: FilteredCriterias){
            
            
            feidForWhereClause= feidForWhereClause +' ' +fc.selectedField + ' '+fc.selectedOpetor + ' \''+fc.inputValue + '\' AND ';
            lstfeildvalueWithoutAnd = feidForWhereClause.Substring(0,feidForWhereClause.length()-4);
            allfieldNames = allfieldNames+fc.selectedField + ',';
            withOutCommaaFeildNames = allfieldNames.removeEnd(',');
            allOperators=allOperators+fc.selectedOpetor+',';
            allInputValue=allInputValue+fc.inputValue+',';
            system.debug('lstfeildvalueWithoutAnd'+lstfeildvalueWithoutAnd);
            system.debug('multiSelectefFiled::'+multiSelectefFiled);
            
        }
        system.debug(FilteredCriterias[0].multiSelectefFiledList);
        String valuesToBeShown = '';//FilteredCriterias[0].multiSelectefFiledList;
        
        if(FilteredCriterias[0].multiSelectefFiledList.size() > 0){
            for(String str : FilteredCriterias[0].multiSelectefFiledList){
                valuesToBeShown = valuesToBeShown+str+',';
            }    
        }
        
        valuesToBeShown = valuesToBeShown.removeEnd(',');
        system.debug('valuesToBeShown'+valuesToBeShown);
        
        
        system.debug('feidForWhereClause'+feidForWhereClause);
        String queryResult = 'SELECT ID ,'+valuesToBeShown+' from '+ObjectName +' where '+lstfeildvalueWithoutAnd;
       						
        DynamicLWCDataTableController.DataTableResponse dtr = DynamicLWCDataTableController.GetWrapperOfSObjectFieldColumnActionValues(ObjectName,valuesToBeShown,valuesToBeShown,queryResult);
    
        return dtr;
    }
    
    @AuraEnabled
    Public static void updateDataInBulk(String objectName,String Fieldname,String inputValue, list<id> selectedRecIds ){
        String query = 'Select id from '+objectName+' where id IN :selectedRecIds';
        system.debug('query'+query);
        system.debug('Fieldname'+Fieldname);
        List<Sobject> dynamicData = database.query(query);
        system.debug('dynamicData'+dynamicData);
        List<Sobject> ListToBeUpdated = new List<Sobject>();
        system.debug('dynamicData'+dynamicData.size());
        for(Sobject obj : dynamicData){
            obj.put(Fieldname,inputValue);
            ListToBeUpdated.add(obj);
        }
        try{
            update ListToBeUpdated;
            system.debug('ListToBeUpdated'+ListToBeUpdated);
        }catch(exception e){
            system.debug(e.getMessage());
        }
        
    }
    
   
    
}