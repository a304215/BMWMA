({
	scriptsLoaded : function(component, event, helper) {
        helper.getReservations(component, event);
        helper.getNextSubjectList(component, event);
    },
    chooseReservation : function(component, event, helper) {
        var res = event.target.id;
        var res2 = '';
        
        var allReser = component.get('v.reservationList');
        for (var i = 0; i < allReser.length; i++) {
            if(allReser[i].Id === res)
            {
                res2 = allReser[i].Opportunity__c;
                component.set('v.selectedReservation', allReser[i]);
            }
        }
    },
    chooseReservation2 : function(component, event, helper) {
        var res = event.target.id;
        var res2 = '';
        
        var allReser = component.get('v.reservationList');
        for (var i = 0; i < allReser.length; i++) {
            if(allReser[i].Id === res)
            {
                component.set('v.selectedReservationOPPId', allReser[i].Opportunity__c);
                component.set('v.selectedReservation', allReser[i]);
            }
        }
        component.set('v.tempWorkLog.CustomerRating__c', 'A');
    },
    save : function(component, event, helper) {
        helper.clearRedLine(component, event);
        helper.saveTheTDR(component, event);
        window && window.scroll(0,0);
    },
})