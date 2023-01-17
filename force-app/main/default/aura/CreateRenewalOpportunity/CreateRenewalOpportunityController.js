({
    doInit : function(component, event, helper) {
        debugger;
        var action = component.get("c.getPickListValuesIntoList");
        action.setParams({
            strObjectName : 'Opportunity',
            strPicklistField : 'StageName'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.stageList",response.getReturnValue());
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    insertOpp: function(component, event, helper) {
        debugger;
        if(component.get("v.selectedValue") == '' || component.get("v.closeDate") == ''){
            alert('Provide Close date and Stage to proceed');
        }
        else{
            var action = component.get("c.createRenewalOpportunity");
            action.setParams({
                stage 		: component.get("v.selectedValue"),
                closeDate 	: component.get("v.closeDate"),
                parentOppId : component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Opportunity Renewed',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'Error Occured',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            });
            $A.get('e.force:refreshView').fire();
            $A.enqueueAction(action);
        }
    }
})