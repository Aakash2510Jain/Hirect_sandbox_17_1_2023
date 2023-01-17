@RestResource(urlMapping='/UserInformation/*')
global class API_UserInfoResponse {
      
    @HttpPost
    global Static responseWrapper QueryUserInformation(){
        responseWrapper responseJSON = new responseWrapper();
        try{
            System.debug('User Email : '+RestContext.request.requestBody.toString());
            UserInfo_client Userdetails = UserInfo_client.parse(RestContext.request.requestBody.tostring());
            System.debug('Userdetails :'+Userdetails.EmailId);
            List<User> Userlist = new List<User>();
            if(!String.isBlank(Userdetails.EmailId)){
                Userlist = [SELECT Alias,Email,FirstName,Id,LastName,Name,Phone,Username FROM User WHERE Email =: Userdetails.EmailId limit 1];
                if(!Userlist.isEmpty()){
                    for(user userRecord : Userlist){
                        responseJSON.Message = 'User Details Found';
                        responseJSON.UserId = userRecord.Id;
                        responseJSON.success = true;
                    }
                }else{
                    responseJSON.Message = 'No User with such email Found in the org';
                    responseJSON.success = false;
                }
                
            } else{
                responseJSON.Message = 'Please Provide User Email';
                responseJSON.success = false;
            }
        }catch(Exception e){
            System.debug('The Error Message is : '+e.getMessage());
        }
        return responseJSON;
    }
    global class responseWrapper{
        global String Message;
        global String UserId;
        global boolean success;
    }


}