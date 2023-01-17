({
    doInit : function(component, event, helper) {
        debugger;
        //{!v.userInfo.Name}
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
    },
    
    copyInputFieldValue : function(component, event, helper) {
        debugger;
        var userRec = component.get("v.userInfo");
        var userRecord;
        if(userRec.Profile.Name.includes("Online")){
            userRecord = "hirect_oonl";
        }else if(userRec.Profile.Name.includes("Offline")){
            userRecord = "hirect_oofl";
        }else{
            userRecord = "hirect_oofl";
        }
        var copyText = 'https://www.test.hirect.in/connect/?utm_source='+userRecord+'&ref_id='+userRec.Id;
        // get textarea field value using aura:id
        var textForCopy = copyText;//component.find('inputFieldId').get("v.value");
        // calling helper class to copy selected text value
        helper.copyTextFieldHelper(component,event,textForCopy);
    },
    
})