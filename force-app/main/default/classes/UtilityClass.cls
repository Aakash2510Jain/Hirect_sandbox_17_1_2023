public with sharing class UtilityClass {
   
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
}