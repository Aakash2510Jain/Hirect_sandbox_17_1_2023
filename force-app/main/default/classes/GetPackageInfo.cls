public without sharing class GetPackageInfo {
    
    @auraEnabled
    Public static string getLeadPackageInfo(String RecordId){
        string message = '';
        Map<String, Object> results;
        try{
            string mobilePhone = [Select id, name, phone From lead where id =: RecordId].phone;
            String endpoint = 'https://1c717udvr5.execute-api.ap-south-1.amazonaws.com/hirect/company-service/salesforce/getPackageInfo?recruiterMobile=+'+mobilePhone;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            string getAccessToken = '00D5j00000BXiJ9!AQwAQEjGy6BNatITHOzUioxkKBqe1u54Dojvcdc1W87NS9nZ.mgy.Kb4ElperFN9tOakUXXHjxerFu7fM80yYQb2hvP3mZjr';
            request.setHeader('token',  getAccessToken);
            HttpResponse response = http.send(request);
            System.debug('response' + response.getBody());
            
            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 200) {
                
                // Deserialize the JSON string into collections of primitive data types.
                results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                
            }
            Map<String,Object> mappedValue = (Map<String,Object>)results.get('data');
            system.debug('mappedValue :: ' + mappedValue);
            if(mappedValue != null){
                lead ld = new lead();
                ld.Id = RecordId;
                ld.Trigger_1day__c =  Decimal.valueOf(String.valueOf(mappedValue.get('trigger1day')));
                ld.Trigger_3day__c = Decimal.valueOf(String.valueOf(mappedValue.get('trigger3day')));
                ld.Clickpay_1day__c = Decimal.valueOf(String.valueOf(mappedValue.get('clickPay1day')));
                ld.Clickpay_3day__c = Decimal.valueOf(String.valueOf(mappedValue.get('clickPay3day')));
                ld.NumberOfLiveJobs__c = Decimal.valueOf(String.valueOf(mappedValue.get('numberOfLiveJobs')));
                ld.Active_level__c = Decimal.valueOf(String.valueOf(mappedValue.get('activeLevel')));
                ld.Chat_level__c = Decimal.valueOf(String.valueOf(mappedValue.get('chatLevel')));
                ld.Double_chat_level__c = Decimal.valueOf(String.valueOf(mappedValue.get('doubleChatLevel')));
                ld.Saved_candidates__c = Decimal.valueOf(String.valueOf(mappedValue.get('savedCandidates')));
                ld.Company_recruiter__c = Decimal.valueOf(String.valueOf(mappedValue.get('savedCandidates')));
                //ld.Company_recruiter__c = decimal.valueof(mappedValue.get('companyRecruiter'));
                update ld;
                message = 'success';
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            message = e.getMessage();
        }
        return message;
    }
    
    
    @auraEnabled
    Public static string getLeadJobInfo(Id RecordId){
        List<Job_Posting__c> jobPostingToBeInserted = new List<Job_Posting__c>();
        String sObjName = RecordId.getSObjectType().getDescribe().getName();
        string message = '';
        try{
            String endpoint = '';
            if(sObjName == 'Account'){
                string mobilePhone = [Select id, name, phone From Account where id =: RecordId].phone;
            	endpoint = 'https://1c717udvr5.execute-api.ap-south-1.amazonaws.com/hirect/company-service/salesforce/getJobInfo?recruiterMobile=+'+mobilePhone;
            }
            else if(sObjName == 'lead'){
                string mobilePhone = [Select id, name, phone From lead where id =: RecordId].phone;
                endpoint = 'https://1c717udvr5.execute-api.ap-south-1.amazonaws.com/hirect/company-service/salesforce/getJobInfo?recruiterMobile=+'+mobilePhone;
            }
            system.debug('endpoint :: ' + endpoint);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('GET');
            string getAccessToken = '00D5j00000BXiJ9!AQwAQEjGy6BNatITHOzUioxkKBqe1u54Dojvcdc1W87NS9nZ.mgy.Kb4ElperFN9tOakUXXHjxerFu7fM80yYQb2hvP3mZjr';
            request.setHeader('token',  getAccessToken);
            HttpResponse response = http.send(request);
            System.debug('response' + response.getBody());
            
            // If the request is successful, parse the JSON response.
            if(response.getStatusCode() == 200) {
                
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
                Map<String,Object> m2 =  (Map<String, Object>) m.get('data');
                List<Object> lstofJobs = (List<Object>)m2.get('jobs');
                system.debug('lstofJobs-->'+lstofJobs);
                
                //{createTime=1654651122403, functionalArea=functionalArea, isRemoteJob=false, jobDescription=jobDescription, jobLocation=jobLocation, jobTitle=jobTitle}
                // DateTime.newInstance(createTime)
                if(lstofJobs != Null){
                    List<Job_Posting__c> existingJobPostings = [Select Id from Job_Posting__c where Lead__c =:RecordId ];
                    Database.delete(existingJobPostings);
                    for(Object obj : lstofJobs){
                        Job_Posting__c jobPostingRec = new Job_Posting__c(); 
                        Map<String,Object> JPMapFromObj = (Map<String,Object>)obj;
                        Long L1 = long.valueOf(String.valueOf(JPMapFromObj.get('createTime')));
                        datetime createddatetime =  DateTime.newInstance(L1);
                        system.debug('JPMapFromObj :: ' + JPMapFromObj);
                        
                        jobPostingRec.Created_Time__c = createddatetime;
                        jobPostingRec.Job_Function__c = String.valueOf(JPMapFromObj.get('functionalArea'));
                        jobPostingRec.Is_remote_Job__c = boolean.valueOf(JPMapFromObj.get('isRemoteJob'));
                        jobPostingRec.Description__c = String.valueOf(JPMapFromObj.get('jobDescription'));
                        jobPostingRec.Job_Location__c = String.valueOf(JPMapFromObj.get('jobLocation'));
                        jobPostingRec.Job_Title__c = String.valueOf(JPMapFromObj.get('jobTitle'));
                        if(sObjName == 'Account'){
                            jobPostingRec.Account__c = RecordId;
                        }
                        else if(sObjName == 'lead'){
                            jobPostingRec.Lead__c = RecordId;
                        }
                        jobPostingToBeInserted.add(jobPostingRec);
                    }
                }
            }
            if(!jobPostingToBeInserted.isempty()){
                insert jobPostingToBeInserted;
                message = 'Success';
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            message = e.getMessage();
        }
        return message;
    }
}