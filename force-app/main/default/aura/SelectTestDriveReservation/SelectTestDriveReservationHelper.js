({
	getReservations : function(component, event) {
        var myAction = component.get("c.getReservations");
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.reservationList",response.getReturnValue());
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
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
        
        $A.enqueueAction(myAction);
	},
    getNextSubjectList : function(component, event) {
        var myAction = component.get("c.getNextSubject");
        
        myAction.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                component.set("v.nextSubjectList",response.getReturnValue());
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
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
        
        $A.enqueueAction(myAction);
    },
    saveTheTDR: function(component, event) {
        var isErrorOccur = false;
        var myWorkLog = component.get('v.tempWorkLog');
        var myNextSubject = component.get('v.selectedSubjectValue');
        var myMessage = "";
        if(myWorkLog.CustomerRating__c === "" || myWorkLog.CustomerRating__c === undefined)
        {
            myMessage += "請輸入客戶級別。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('customerRating');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        if(myWorkLog.Description__c === "" || myWorkLog.Description__c === undefined)
        {
            myMessage += "請輸入洽談內容。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('contactDescription');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        if(myWorkLog.ExpectedNextDueDate__c === "" || myWorkLog.ExpectedNextDueDate__c === undefined)
        {
            myMessage += "請輸入下次聯繫日期。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('nextDate');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        if(myNextSubject === "" || myNextSubject === undefined)
        {
            myMessage += "請輸入下次聯繫主題。<br/>";
            isErrorOccur = true;
            var cmpTarget = component.find('nextSubject');
    		$A.util.addClass(cmpTarget, 'redLine');
        }
        if(! isErrorOccur)
        {
            
            if(myWorkLog.NoCheck__c === undefined || myWorkLog.NoCheck__c === false)
            {
                var returnTime = component.get('v.selectedReservation').ReturnTime__c.substring(0,10);
                /*
                alert(returnTime);
                var today = new Date();
                var dd = today.getDate();
                var mm = today.getMonth()+1; //January is 0!
                var yyyy = today.getFullYear();
                if(dd<10) {
                    dd = '0'+dd
                } 
                if(mm<10) {
                    mm = '0'+mm
                } 
                today = yyyy+'-'+mm+'-'+dd;
                var m1 = moment(today, 'YYYY-MM-DD');
                */
                var m1 = moment(returnTime, 'YYYY-MM-DD');
                var m2 = moment(myWorkLog.ExpectedNextDueDate__c, 'YYYY-MM-DD');
                var du = m2.diff(m1, 'days');
                if(du <0)
                {
                    myMessage += "不可輸入以前的日期。<br/>";
                    isErrorOccur = true;
                    var cmpTarget = component.find('nextDate');
                    $A.util.addClass(cmpTarget, 'redLine');
                }
                else
                {
                    switch (myWorkLog.CustomerRating__c)
                    {
                        case 'A':
                            if(du>3)
                            {
                                myMessage += "A級客戶須3日內聯繫。<br/>";
                                isErrorOccur = true;
                                var cmpTarget = component.find('nextDate');
                                $A.util.addClass(cmpTarget, 'redLine');
                            }
                            break;
                        case 'B':
                            if(du>7)
                            {
                                myMessage += "B級客戶須7日內聯繫。<br/>";
                                isErrorOccur = true;
                                var cmpTarget = component.find('nextDate');
                                $A.util.addClass(cmpTarget, 'redLine');
                            }
                            break;
                        case 'C':
                            if(du>30)
                            {
                                myMessage += "C級客戶須30日內聯繫。<br/>";
                                isErrorOccur = true;
                                var cmpTarget = component.find('nextDate');
                                $A.util.addClass(cmpTarget, 'redLine');
                            }
                            break;
                            /* 假設只有A、B、C 三個可以選。
                    case 'D':
                        break;
                    case 'E':
                        break;
                    case 'F':
                        break;
                    case 'P':
                        break;
                    */
                    }
                }      
            }
            else
            {
                if(myWorkLog.ReasonOfNonCheck__c === undefined || myWorkLog.ReasonOfNonCheck__c === false)
                {
                    myMessage += "不做檢核請輸入原因。<br/>";
                    isErrorOccur = true;
                    var cmpTarget = component.find('noCheckReason');
                    $A.util.addClass(cmpTarget, 'redLine');
                }
            }
        }

        component.set('v.errorMessage', myMessage);
        if(isErrorOccur)
        {
        }
        else
        {
            var myAction = component.get("c.saveTheReservation");
            
            //傳入event id。
            myAction.setParams({
                inputId : component.get('v.selectedReservation.Id'),
                inputRating : component.get('v.tempWorkLog.CustomerRating__c'),
                inputDescription : component.get('v.tempWorkLog.Description__c'),
                inputDate : component.get('v.tempWorkLog.ExpectedNextDueDate__c'),
                inputSubject : component.get('v.selectedSubjectValue'),
                inputCheck : component.get('v.tempWorkLog.NoCheck__c'),
                inputReason : component.get('v.tempWorkLog.ReasonOfNonCheck__c')
            });
            
            myAction.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    component.set('v.isSaved', true);
                    var evt = $A.get("e.c:PassSurvey");
                    evt.setParams({"PassReservation" : component.get('v.selectedReservation.Id')});
                    evt.setParams({"PassOpportunity" : component.get('v.selectedReservationOPPId')});
                    evt.fire();
                } else if (state === "INCOMPLETE") {
                    // do something
                } else if (state === "ERROR") {
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
            
            $A.enqueueAction(myAction);
        }
    },
    clearRedLine : function(component, event) {
        var cmpTargetCustomerRating = component.find('customerRating');
    	$A.util.removeClass(cmpTargetCustomerRating, 'redLine');
        var cmpTargetcontactDescription = component.find('contactDescription');
    	$A.util.removeClass(cmpTargetcontactDescription, 'redLine');
        var cmpTargetNextDate = component.find('nextDate');
    	$A.util.removeClass(cmpTargetNextDate, 'redLine');
        var cmpTargetNextSubject = component.find('nextSubject');
    	$A.util.removeClass(cmpTargetNextSubject, 'redLine');
        var cmpnoCheckReason = component.find('noCheckReason');
        $A.util.removeClass(cmpnoCheckReason, 'redLine');
    },
})