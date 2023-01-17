public with sharing class DynamicLWCDataTableController {
    @AuraEnabled(cacheable=true)
    public static DataTableResponse GetWrapperOfSObjectFieldColumnActionValues(String objName,String allFieldName,String HeaderName,String DynamicQuery )
    {
        system.debug('allFieldName'+allFieldName);
        system.debug('HeaderName'+HeaderName);
        system.debug('DynamicQuery'+DynamicQuery);
        List<DataTableColumns> lstDataColumns            = new List<DataTableColumns>();
        List<SObject> lstDataTableData                   = new List<SObject>();
        List<string> columnList                          = new List<string>();
        List<string> fieldAPINameList                    = new List<string>();
        
        if(HeaderName != null)
        {
            columnList = HeaderName.split(',');
        }
        
        if(fieldAPINameList != null)
        {
            fieldAPINameList = allFieldName.split(',');
        }
        
        for(integer i = 0; i < columnList.size(); i++)
        {
            
            DataTableColumns datacolumns = new DataTableColumns( getFieldNamesByObject(objName , columnList[i].trim()),getFieldNamesByObject(objName,fieldAPINameList[i].substringBefore(':').trim()),'text',true);
            lstDataColumns.add(datacolumns);
        }
        
        for(SObject SObjectItem : Database.query(DynamicQuery))
        {
            lstDataTableData.add(SObjectItem);
        }
        
        DataTableResponse finalWrapper   = new DataTableResponse();
        finalWrapper.TableTitle          = 'LWC Table';
        finalWrapper.lstDataTableColumns = lstDataColumns;
        finalWrapper.lstDataTableData    = lstDataTableData;
        return finalWrapper;
    }
    
    public class DataTableColumns {
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Boolean editable {get;set;}
        
        public DataTableColumns(String label, String fieldName, String type,Boolean editable )
        {
            this.label     = label;
            this.fieldName = fieldName;
            this.type      = type;
            this.editable = editable;
        }
    }
    
    public class DataTableResponse {
        @AuraEnabled
        public List<DataTableColumns> lstDataTableColumns {get;set;}
        @AuraEnabled
        public List<sObject> lstDataTableData {get;set;}
        @AuraEnabled
        public String TableTitle {get;set;}       
    }
    
    
    public static String getFieldNamesByObject(String ObjName ,String fieldName){
       
        String properName = '';
        Map<String, Schema.SObjectField> M_Objects_Schema_Field = Schema.getGlobalDescribe().get(ObjName).getDescribe().fields.getMap();
        Map<String,String> fieldApiNameByLabelName = new map<String,String>();
        
        for( String a_Field_Name : M_Objects_Schema_Field.keySet() ) {
            Schema.DescribeFieldResult a_Field_Description = M_Objects_Schema_Field.get( a_Field_Name ).getDescribe();
            fieldApiNameByLabelName.put(a_Field_Description.getName().toUpperCase(),a_Field_Description.getName());
        }
        system.debug('fieldApiNameByLabelName'+fieldApiNameByLabelName);
        return properName = fieldApiNameByLabelName.get(fieldName.toUpperCase());
    }
    
    
}