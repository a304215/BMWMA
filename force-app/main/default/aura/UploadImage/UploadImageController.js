({
	init : function(component, event, helper) {
		component.set("v.theRecordId", component.get("v.recordId"));
	},
    handleUploadFinished: function (component, event, helper) {
        helper.LinkStart(component, event);
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : "success",
            "message": "file has been updated successfully!"
        });
        toastEvent.fire();
  
        $A.get('e.force:refreshView').fire();
        console.log('fire');
        location.reload();
    }
})