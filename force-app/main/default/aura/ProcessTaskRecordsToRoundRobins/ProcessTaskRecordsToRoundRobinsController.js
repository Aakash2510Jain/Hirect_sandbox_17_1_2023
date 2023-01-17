({
    onPageReferenceChange: function (cmp, evt, helper) {
        debugger;
        var myPageRef = cmp.get("v.pageReference");
        var label = $A.get("$Label.c.listViewId");
        var tasks = myPageRef.state.c__listofTasks;
        helper.GetAssignmentgroup(cmp, evt);
        console.log('Listoftasks', JSON.stringify(tasks));
        
        if(tasks.length < 1 || tasks == ""){
            //alert("Please Select Task")
            helper.showWarning(cmp, evt);
            var navEvent = $A.get("e.force:navigateToList");
         navEvent.setParams({
             "listViewId": label,
             "listViewName": "All Tasks",
             "scope": "Task"
         });
         //toastEvent.fire();
         navEvent.fire();
            
        }
        else{
            var TasksArr = tasks.split(',');
            cmp.set("v.Listoftasks", TasksArr);
            //var AssignmentGroupList = [];
            cmp.set("v.isModalOpen", true);
            //split the account ids by comma and continue logic
            
        }

        /*var tasksArr = tasks.split(',');
        cmp.set("v.Listoftasks", tasksArr);
        //var AssignmentGroupList = [];
        helper.GetAssignmentgroup(cmp, evt);
        cmp.set("v.isModalOpen", true);
        //split the account ids by comma and continue logic*/
    },
    closeModel: function (component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        var taskListView = component.get("v.AllTaskListview");
        component.set("v.isModalOpen", false);
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewId": taskListView.Id,
            "listViewName": taskListView.Name,
            "scope": "task"
        });
        navEvent.fire();
    },

    submitDetails: function (component, event, helper) {
        debugger;
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        var selectedAssignGroupForJs = component.get("v.SelectedAssignGroup");
        var tasklistids = component.get("v.Listoftasks");

        var action = component.get('c.TransferTask');
        action.setParams({
            taskListId: tasklistids,
            SelectedAssignGroup: selectedAssignGroupForJs
        });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var serverResponse = response.getReturnValue();

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Success',
                    message: 'Task has been Assigned to the Selected Group successFully!!!!!',
                    duration: ' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();

                var taskListView = component.get("v.AllTaskListview");
                component.set("v.isModalOpen", false);
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": taskListView.Id,
                    "listViewName": taskListView.Name,
                    "scope": "task"
                });
                navEvent.fire();
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
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
})