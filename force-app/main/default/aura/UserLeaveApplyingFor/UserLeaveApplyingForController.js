({
    onload: function (component, event, helper) {
        debugger;
        //var currentLeadId = component.get("v.recordId");
        var action = component.get("c.userdetailsonDoint");

        action.setCallback(this, function (response) {
            var state = response.getState();

            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse != null) {
                    
                    if (storeResponse.Leave_Start_Date__c != '' && storeResponse.Leave_End_Date__c != '' && storeResponse.Leave_Start_Date__c != undefined && storeResponse.Leave_End_Date__c != undefined) {
                        //component.set("v.RescheduleCheckbox", true);
                        component.set("v.Enddate", storeResponse.Leave_End_Date__c);
                        component.set("v.Startdate", storeResponse.Leave_Start_Date__c);
                        component.set("v.DisableDLeaveDate", true);
                        component.set("v.disableButton", true);
                    }

                }

            }
        });
        //4. Add This Method to Action
        $A.enqueueAction(action);
    },
    ApplyForLeave : function (component, event, helper){
        debugger;
        var startdateForJs = component.get("v.Startdate");
        var EnddateForJs = component.get("v.Enddate");

        var addEvent = component.get("c.UpdateUserDetails");

            // 2. Add parameters to Refrence Var
            addEvent.setParams({
                'LeaveStartdate': startdateForJs,
                'LeaveEnddate': EnddateForJs
            });

            //3. Provide Callback method
            addEvent.setCallback(this, function (response) {
                var state = response.getState();

                if (state === "SUCCESS") {
                    var storeResponse = response.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Leave Request has been submitted Successfully!!!."
                    });
                    toastEvent.fire();
                    var a = component.get('c.onload');
                    $A.enqueueAction(a);
                    //location.reload();
                    //$A.get("e.force:closeQuickAction").fire();
                }

            });

            //4. Add This Method to Action
            $A.enqueueAction(addEvent);
    },

    handleStartChange: function (component, event, helper) {
        debugger;
        var startdateForJs = component.get("v.Startdate");
        //var EnddateForJs = component.get("v.Enddate");

        var SartdatetimeforNow = new Date(startdateForJs);
        var EnddatetimeforNow = SartdatetimeforNow;
        var today = new Date();
        const oneMinuteInMillis = 1 * 60 * 1000;
        var dateTocheck = today.setTime(today.getTime() - oneMinuteInMillis);

        if (SartdatetimeforNow.getTime() < dateTocheck) {
            alert('Start time should be greater then current time!');
            component.set("v.Startdate", '');
            component.set("v.Enddate", '');
            //component.set("v.FieldSetBoolean", true);
            
        }
        /*else if(){

        }*/
    },

    handleEndChange : function(component, event, helper){
        debugger;
        var enddatetime = component.get("v.Enddate");
        var EnddatetimeforNow = new Date(enddatetime);
        var enddatetimeInMs = EnddatetimeforNow.getTime();
        var startdatetime = component.get("v.Startdate");
        var StartdatetimeforNow = new Date(startdatetime);
        var startdatetimeInMs = StartdatetimeforNow.getTime();
        var timediffInmin = ((enddatetimeInMs - startdatetimeInMs)/(1000*60));

        /*if(timediffInmin > 60){
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Warning',
                        message: 'Meeting Length cannot be Greater than 1 hour!!!',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'warning',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    enddatetimeInMs = startdatetimeInMs + 1000*60*60;
                    var EnddatetimePlusOneHour = new Date(enddatetimeInMs).toISOString();
        component.set("v.Eventrecord.EndDateTime", EnddatetimePlusOneHour);  
        }*/

        if(EnddatetimeforNow < StartdatetimeforNow ){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Warning',
                message: 'End Date Cannot be less than Start DateTime!!!!!',
                duration: ' 5000',
                key: 'info_alt',
                type: 'warning',
                mode: 'pester'
            });
            toastEvent.fire();
            //enddatetimeInMs = startdatetimeInMs;
            //var EnddatetimePlusOneHour = new Date(enddatetimeInMs).toISOString();
            component.set("v.Enddate", '');

        }
    }
})