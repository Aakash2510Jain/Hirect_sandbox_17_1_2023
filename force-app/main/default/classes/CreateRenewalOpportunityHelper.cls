public class CreateRenewalOpportunityHelper {
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(String strObjectName, String strPicklistField){
        system.debug('strObjectName::'+strObjectName);
        system.debug('strPicklistField::'+strPicklistField);
        List<String> pickListValuesList= new List<String>();
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for( Schema.PicklistEntry pickListVal : lstPickListValues){
            pickListValuesList.add(pickListVal.getLabel());
        }
        system.debug('pickListValuesList::>'+pickListValuesList);
        return pickListValuesList;
    }
    @AuraEnabled
    public static void createRenewalOpportunity(String stage, Date closeDate, string parentOppId){
        try{
            if(!String.isBlank(parentOppId)){
                Opportunity parentOpp = [select AccountId,Amount,Budget_Confirmed__c,Description,Discount__c,Discovery_Completed__c,ExpectedRevenue,ForecastCategoryName,Lead_generated_by__c,
                                         LeadSource,Loss_Reason__c,NextStep,Name,OwnerId,IqScore,Opportunity_Type__c,Probability,TotalOpportunityQuantity,ROI_Analysis_Completed__c,Type From Opportunity
                                         Where Id = :parentOppId];
                if(parentOpp != null){
                    Opportunity oppRec = new Opportunity(
                        AccountId = parentOpp.AccountId,
                        Amount = parentOpp.Amount,
                        Budget_Confirmed__c = parentOpp.Budget_Confirmed__c,
                        Description = parentOpp.Description,
                        Discount__c = parentOpp.Discount__c,
                        Discovery_Completed__c = parentOpp.Discovery_Completed__c,
                        ForecastCategoryName = parentOpp.ForecastCategoryName,
                        Lead_generated_by__c = parentOpp.Lead_generated_by__c,
                        LeadSource = parentOpp.LeadSource,
                        Loss_Reason__c = parentOpp.Loss_Reason__c,
                        NextStep = parentOpp.NextStep,
                        Name = parentOpp.Name +' - '+convertNumberToMonth(closeDate.Month()),
                        OwnerId = parentOpp.OwnerId,
                        Probability = parentOpp.Probability,
                        TotalOpportunityQuantity = parentOpp.TotalOpportunityQuantity,
                        ROI_Analysis_Completed__c = parentOpp.ROI_Analysis_Completed__c,
                        Type = parentOpp.Type,
                        Parent_opportunity__c = parentOppId,
                        CloseDate = closeDate,
                        StageName = stage,
                        Opportunity_Type__c = 'Renewable Record'
                    );
                    insert oppRec;
                }
                
            }
        }catch(exception ex){
            system.debug('Error-->'+ex.getMessage());
            system.debug('Error@@-->'+ex.getLineNumber());
            
        }        
    }
    public static String convertNumberToMonth(integer monthIntVal){
        String month = '';
        if(monthIntVal > 0 && monthIntVal <13){
            
            if(monthIntVal == 1){
                month =  'January';   
            }else if(monthIntVal == 2){
                month = 'February';   
            }else if(monthIntVal == 3){
                month = 'March';   
            }else if(monthIntVal == 4){
                month = 'April';   
            }else if(monthIntVal == 5){
                month = 'May';       
            }else if(monthIntVal == 6){            
                month = 'June';   
            }else if(monthIntVal == 7){
                month = 'July';   
            }else if(monthIntVal == 8){
                month = 'August';   
            }else if(monthIntVal == 9){
                month = 'September';   
            }else if(monthIntVal == 10){
                month = 'October';  
            }else if(monthIntVal == 11){
                month = 'November';  
            }else{
                month = 'December';
            }
        }
        return month;
    }
}