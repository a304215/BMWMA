({
    LinkStart : function(component, event){
        var uploadedFile = event.getParam("files")[0];
        var documentId = uploadedFile.documentId;

        var action = component.get('c.publicLinkStart');
        // Set up the callback
        action.setParams({
            'inputDocumentId' : documentId,
            'inputId' : component.get('v.theRecordId'),
            'inputObject' : component.get('v.objectName'),
            'inputField' : component.get('v.fieldName')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
				component.set('v.IMGURL', response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
            
        });
        $A.enqueueAction(action);
    },
})