({
    doInit : function(component, event, helper){
        debugger;
    
        var recID = component.get("v.recordId");
        //var param = window.location.href;
        var action = component.get("c.UpdateLeadSourceAndOwner");
        debugger;
        action.setParams({
            RecID: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (response.getState() === "SUCCESS") {
                var serverresponse = response.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Lead Owner and Stage Have been updated successfully!!!!!',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
            }
                
        });
        $A.enqueueAction(action);
    },
    
})