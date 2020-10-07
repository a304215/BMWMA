({
	setToday: function(component) {
        var action = component.get("c.getMyDay");
        var DD = component.get('v.choosenDate');
        
        action.setParams({
            'inputDate': DD
        });
        
        //set callback   
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                //for SF1，因為無法直接吃new Date(2018-01-01);
                var tempD = DD.split("-");
                var theDay = new Date(tempD[0], tempD[1]-1, tempD[2]);

                component.set('v.allWeekDays', response.getReturnValue());
                component.set('v.theIndex',theDay.getDay());
            }
        });
        $A.enqueueAction(action);
    },
})