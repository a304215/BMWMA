({
	getResult : function(component, event, helper) {
		var myResult = event.getParam("PassOpportunity");
        component.set("v.Get_Result9", myResult);
        //給預設值。
        helper.getOpprotunity(component, event);
    },
})