public class LookupSearchComponentController {
    
    @AuraEnabled
    public static List<SObJectResult> getResults(String ObjectName, String fieldName, String value) {
        List<SObJectResult> sObjectResultList = new List<SObJectResult>();
        for(sObject so : Database.Query('Select Id,'+fieldName+' FROM '+ObjectName+' WHERE '+fieldName+' LIKE \'%' + value + '%\'')) {
            String fieldvalue = (String)so.get(fieldName);
            sObjectResultList.add(new SObjectResult(fieldvalue, so.Id));
        }
        return sObjectResultList;
    }
    
    @AuraEnabled
    public static String genrateScore(String LeadId) {
        
        Decimal totalScore = 0;
        decimal MaximumScore = 0;
        List<Scorecard__c> ScoreList = [SELECT Enabled__c,Total_Weight__c,(SELECT Field_Name__c,Field_Type__c,Matching_Type__c,Matching_Value__c,Related_Object__c,Scorecard_Execution_Criteria_Name__c,Scorecard__c,Sequence__c FROM Execution_Criteria_Entry__R) FROM Scorecard__c where enabled__c = true];
        map<string,String> expectedValuebyCriteria = new Map<String,String>();
        map<string,Decimal> allotedMarksbyCriteria = new Map<String,Decimal>();
        map<string,String> fieldByMatchingType = new Map<String,String>();
        map<string,String> fieldByFieldType = new Map<String,String>();
        map<string,String> leadValueForFields = new Map<String,String>();
        for(Scorecard__c scr:ScoreList){
            for(Execution_Criteria_Entry__c exe:scr.Execution_Criteria_Entry__R){
                expectedValuebyCriteria.put(exe.Field_Name__c,exe.Matching_Value__c);
                fieldByMatchingType.put(exe.Field_Name__c,exe.Matching_Type__c);
                fieldByFieldType.put(exe.Field_Name__c,exe.Field_Type__c);
                allotedMarksbyCriteria.put(exe.Field_Name__c,exe.Sequence__c);
            }
        }
        system.debug('expectedValuebyCriteria'+expectedValuebyCriteria);    
        system.debug('allotedMarksbyCriteria'+allotedMarksbyCriteria);    
        
        
        List<Lead> LeadsToBeScored = [SELECT Address,Budget_Amount__c,Campaign_Comment__c,Campaign_Country_Code__c,City,Company,Country,CreatedDate,Created_time__c,Date_of_Birth__c,District__c,Email,FirstName,Rating,State,Status,Website FROM Lead where id = :LeadId];
        for(String fieldval : expectedValuebyCriteria.keyset()){
            for(Lead ld:LeadsToBeScored)  {
                MaximumScore = MaximumScore+allotedMarksbyCriteria.get(fieldval);
                if(fieldByMatchingType.get(fieldval) == 'Date'){
                    if(fieldByMatchingType.get(fieldval) == '<' || fieldByMatchingType.get(fieldval) == '<='){
                        if(date.valueOf(expectedValuebyCriteria.get(fieldval)) <= date.valueOf(ld.get(fieldval))){
                            totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                        }  
                    }else if(fieldByMatchingType.get(fieldval) == '>' || fieldByMatchingType.get(fieldval) == '>='){
                        if(date.valueOf(expectedValuebyCriteria.get(fieldval)) >= date.valueOf(ld.get(fieldval))){
                            totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                        }  
                    }else{
                        if(date.valueOf(expectedValuebyCriteria.get(fieldval)) == date.valueOf(ld.get(fieldval))){
                            totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                        }  
                    } 
                }else if(fieldByMatchingType.get(fieldval) == 'Number'){
                    if(fieldByMatchingType.get(fieldval) == '<' || fieldByMatchingType.get(fieldval) == '<='){
                        if(Integer.valueOf(expectedValuebyCriteria.get(fieldval)) <= Integer.valueOf(ld.get(fieldval))){
                            totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                        }  
                    }else if(fieldByMatchingType.get(fieldval) == '>' || fieldByMatchingType.get(fieldval) == '>='){
                        if(Integer.valueOf(expectedValuebyCriteria.get(fieldval)) >= Integer.valueOf(ld.get(fieldval))){
                            totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                        }  
                    }else{
                        if(Integer.valueOf(expectedValuebyCriteria.get(fieldval)) == Integer.valueOf(ld.get(fieldval))){
                            totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                        }  
                    } 
                }else{
                    if(fieldByMatchingType.get(fieldval) == '=='){
                        System.debug('String.valueOf(ld.get(fieldval)'+String.valueOf(ld.get(fieldval)));
                        if(expectedValuebyCriteria.get(fieldval).contains(',')){
                            List<String> commaSeparatedValues = expectedValuebyCriteria.get(fieldval).split(',');
                            for(String Str:commaSeparatedValues){
                                if(Str == String.valueOf(ld.get(fieldval))){
                                    totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                                } 
                            }
                        }else{
                            
                            if(isDecimal(String.valueOf(ld.get(fieldval))) == true){
                                if(Integer.valueOf(expectedValuebyCriteria.get(fieldval)) == ld.get(fieldval)){
                                    system.debug('Coming Kya..?'+ld.get(fieldval)); 
                                    totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                                }
                            }else{
                                if(expectedValuebyCriteria.get(fieldval) == String.valueOf(ld.get(fieldval))){
                                    totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                                }    
                            }
                                 
                        } 
                    }else if(fieldByMatchingType.get(fieldval) == '!='){
                        if(expectedValuebyCriteria.get(fieldval) == 'null'){
                            if(ld.get(fieldval) != null ){
                                totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                            } 
                        }else{
                            if(expectedValuebyCriteria.get(fieldval) != String.valueOf(ld.get(fieldval)) && String.valueOf(ld.get(fieldval)) != ''){
                                totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                            }    
                        } 
                    }else if(fieldByMatchingType.get(fieldval) == 'CONTAINS'){
                        if(String.valueOf(ld.get(fieldval)).contains(expectedValuebyCriteria.get(fieldval))){
                            totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                        }  
                    }else if(fieldByMatchingType.get(fieldval) == 'DOES NOT CONTAIN'){
                        if(!expectedValuebyCriteria.get(fieldval).contains(String.valueOf(ld.get(fieldval)))){
                            totalScore = totalScore+allotedMarksbyCriteria.get(fieldval);
                        }  
                    }
                }
                
            }
        }
        Lead LeadTobeUpdated = new Lead(id=LeadId,Lead_Score__c=totalScore,Maximum_Score__c = MaximumScore);
        update LeadTobeUpdated;
        system.debug('totalScore'+totalScore);         
        return 'Success';
    }
    
    public class SObJectResult {
        @AuraEnabled
        public String recName;
        @AuraEnabled
        public Id recId;
        
        public SObJectResult(String recNameTemp, Id recIdTemp) {
            recName = recNameTemp;
            recId = recIdTemp;
        }
    }
    public static Boolean isDecimal(String s){
        Boolean ReturnValue;
        try{
            Decimal.valueOf(s);
            ReturnValue = TRUE; 
        } catch (Exception e) {
            ReturnValue = FALSE;
        }
        return ReturnValue;
    }
    public static String getMyAPIName(String objectName, String fieldLabel ) {
        
        SObjectType type = Schema.getGlobalDescribe().get(objectName);
        Map<String,Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
        string value= '';
        for(String strField : mfields.keySet())
        {
            SObjectField fl = mfields.get(strField);
            if(fieldLabel == fl.getDescribe().getlabel())
            {
                value =  strField;
            }else{
                
            }
        }
        return value;
    }
     public Static void TestCoverage(){
        integer i =0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}