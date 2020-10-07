({
    doInit: function(component, event, helper) {
        var selectCmp1 = component.find("InputSelectSingleConfirmA");
        selectCmp1.set("v.value", component.get("v.TheContent.theMessage.ConfirmActionTypeA__c"));

        var selectCmp2 = component.find("InputSelectSingleConfirmB");
        selectCmp2.set("v.value", component.get("v.TheContent.theMessage.ConfirmActionTypeB__c"));

        var selectCmp3 = component.find("InputSelectSingleFlexWidth");
        selectCmp3.set("v.value", component.get("v.TheContent.theMessage.FlexSize__c"));

        var returnList = component.get('v.TheContentList');
        var myCount=0;
        for(var i=0; i<returnList.length;i++)
        {
            if(returnList[i].isDeleted__c===false)
            {
                myCount++;
                returnList[i].Index__c = myCount;
            }
        }
        //component.set('v.TheContentList', returnList);
        component.set('v.contentCount', myCount);
    },
    removeMe : function(component, event, helper) {
        component.set('v.TheContent.theMessage.isDeleted__c', true);
        var myPassEvent = component.getEvent("passEvent");
        myPassEvent.setParams({
            "message" : 1
        });
        myPassEvent.fire();
    },
    countText : function(component, event, helper) {
        var BString = component.get('v.TheContent.theMessage.Text__c');
        if(BString === undefined)
        {
            BString = '';
        }
		component.set('v.StringTextCount', BString.length);
    },
    countText2 : function(component, event, helper) {
        var BString = component.get('v.TheContent.theMessage.ConfirmText__c');
        if(BString === undefined)
        {
            BString = '';
        }
		component.set('v.StringTextCount2', BString.length);
    },
    ChoseText : function(component, event, helper) {
        component.set('v.TheContent.theMessage.MessageType__c', '文字');
	},
    ChoseTexture : function(component, event, helper) {
		component.set('v.TheContent.theMessage.MessageType__c', '貼圖');
	},
    ChosePic : function(component, event, helper) {
		component.set('v.TheContent.theMessage.MessageType__c', '圖片');
	},
    ChosePicText : function(component, event, helper) {
		component.set('v.TheContent.theMessage.MessageType__c', '圖文');
	},
    ChoseVideo : function(component, event, helper) {
        component.set('v.TheContent.theMessage.MessageType__c', '影片');
    },
    ChoseConfirm : function(component, event, helper) {
        component.set('v.TheContent.theMessage.MessageType__c', '確認');
    },
    ChoseCarousel : function(component, event, helper) {
        component.set('v.TheContent.theMessage.MessageType__c', '輪播');
    },
    ChosePostback : function(component, event, helper) {
        component.set('v.TheContent.theMessage.MessageType__c', 'postback');
    },
    ShowEMOJI : function(component, event, helper) {
        component.set('v.ShowEMOJI', true);	
    },
    HideEMOJI : function(component, event, helper) {
    component.set('v.ShowEMOJI', false);
    },
    choseMe : function(component, event, helper) {
        var idx = event.target.id;
        var BString = component.get('v.TheContent.theMessage.Text__c');
        if(BString === undefined)
        {
            BString = '';
        }
        BString += idx;
        component.set('v.TheContent.theMessage.Text__c', BString);
    },
    ShowSticker : function(component, event, helper) {
        component.set('v.ShowSticker', true);
    },
    HideSticker: function(component, event, helper) {
        component.set('v.ShowSticker', false);
    },
    ShowSticker37 : function(component, event, helper) {
        component.set('v.ShowStickerPackage', '11537');
    },
    ShowSticker38 : function(component, event, helper) {
        component.set('v.ShowStickerPackage', '11538');	
    },
    ShowSticker39 : function(component, event, helper) {
        component.set('v.ShowStickerPackage', '11539');	
    },
    choseMeSticker37 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PackageID__c', '11537');
        var idx = event.target.id;
        component.set('v.TheContent.theMessage.StickerID__c', idx);
        component.set('v.ShowSticker', false);
    },
    choseMeSticker38 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PackageID__c', '11538');
        var idx = event.target.id;
        component.set('v.TheContent.theMessage.StickerID__c', idx);
        component.set('v.ShowSticker', false);
    },
    choseMeSticker39 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PackageID__c', '11539');
        var idx = event.target.id;
        component.set('v.TheContent.theMessage.StickerID__c', idx);
        component.set('v.ShowSticker', false);
    },
    handleUploadFinished: function (component, event, helper) {
        helper.LinkStart(component, event);
    },
    handleUploadFinished2: function (component, event, helper) {
        helper.LinkStart2(component, event);
    },
    picTextChose1 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PicTextType__c', 'type1');
    },
    picTextChose2 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PicTextType__c', 'type2');
    },
    picTextChose3 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PicTextType__c', 'type3');
    },
    picTextChose4 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PicTextType__c', 'type4');
    },
    picTextChose5 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PicTextType__c', 'type5');
    },
    picTextChose6 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PicTextType__c', 'type6');
    },
    picTextChose7 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PicTextType__c', 'type7');
    },
    picTextChose8 : function(component, event, helper) {
        component.set('v.TheContent.theMessage.PicTextType__c', 'type8');
    },
    ShowPicTextA : function(component, event, helper) {
        component.set('v.ShowPicTextA', true);
        component.set('v.PicTextOld_Type', component.get('v.TheContent.theMessage.PicTextTypeA__c'));
        component.set('v.PicTextOld_Title', component.get('v.TheContent.theMessage.PicTextTitleA__c'));
        component.set('v.PicTextOld_Text', component.get('v.TheContent.theMessage.PicTextMTextA__c'));
    },
    onSingleSelectChangeA: function(component) {
        var selectCmp = component.find("InputSelectSingleA");
        component.set("v.TheContent.theMessage.PicTextTypeA__c", selectCmp.get("v.value"));
    },
    HidePicTextA : function(component, event, helper) {
        component.set('v.ShowPicTextA', false);
    },
    CancelPicTextA : function(component, event, helper) {
        component.set('v.ShowPicTextA', false);
        component.set('v.TheContent.theMessage.PicTextTypeA__c', component.get('v.PicTextOld_Type'));
        component.set('v.TheContent.theMessage.PicTextTitleA__c', component.get('v.PicTextOld_Title'));
        component.set('v.TheContent.theMessage.PicTextMTextA__c', component.get('v.PicTextOld_Text'));
        var selectCmpA = component.find("InputSelectSingleA");
        selectCmpA.set("v.value", component.get('v.PicTextOld_Type'));
    },
    ShowPicTextB : function(component, event, helper) {
        component.set('v.ShowPicTextB', true);
        component.set('v.PicTextOld_Type', component.get('v.TheContent.theMessage.PicTextTypeB__c'));
        component.set('v.PicTextOld_Title', component.get('v.TheContent.theMessage.PicTextTitleB__c'));
        component.set('v.PicTextOld_Text', component.get('v.TheContent.theMessage.PicTextMTextB__c'));
    },
    onSingleSelectChangeB: function(component) {
        var selectCmp = component.find("InputSelectSingleB");
        component.set("v.TheContent.theMessage.PicTextTypeB__c", selectCmp.get("v.value"));
    },
    HidePicTextB : function(component, event, helper) {
        component.set('v.ShowPicTextB', false);
    },
    CancelPicTextB : function(component, event, helper) {
        component.set('v.ShowPicTextB', false);
        component.set('v.TheContent.theMessage.PicTextTypeB__c', component.get('v.PicTextOld_Type'));
        component.set('v.TheContent.theMessage.PicTextTitleB__c', component.get('v.PicTextOld_Title'));
        component.set('v.TheContent.theMessage.PicTextMTextB__c', component.get('v.PicTextOld_Text'));
        var selectCmpB = component.find("InputSelectSingleB");
        selectCmpB.set("v.value", component.get('v.PicTextOld_Type'));
    },
    ShowPicTextC : function(component, event, helper) {
        component.set('v.ShowPicTextC', true);
        component.set('v.PicTextOld_Type', component.get('v.TheContent.theMessage.PicTextTypeC__c'));
        component.set('v.PicTextOld_Title', component.get('v.TheContent.theMessage.PicTextTitleC__c'));
        component.set('v.PicTextOld_Text', component.get('v.TheContent.theMessage.PicTextMTextC__c'));
    },
    onSingleSelectChangeC: function(component) {
        var selectCmp = component.find("InputSelectSingleC");
        component.set("v.TheContent.theMessage.PicTextTypeC__c", selectCmp.get("v.value"));
    },
    HidePicTextC : function(component, event, helper) {
        component.set('v.ShowPicTextC', false);
    },
    CancelPicTextC : function(component, event, helper) {
        component.set('v.ShowPicTextC', false);
        component.set('v.TheContent.theMessage.PicTextTypeC__c', component.get('v.PicTextOld_Type'));
        component.set('v.TheContent.theMessage.PicTextTitleC__c', component.get('v.PicTextOld_Title'));
        component.set('v.TheContent.theMessage.PicTextMTextC__c', component.get('v.PicTextOld_Text'));
        var selectCmpC = component.find("InputSelectSingleC");
        selectCmpC.set("v.value", component.get('v.PicTextOld_Type'));
    },
    ShowPicTextD : function(component, event, helper) {
        component.set('v.ShowPicTextD', true);
        component.set('v.PicTextOld_Type', component.get('v.TheContent.theMessage.PicTextTypeD__c'));
        component.set('v.PicTextOld_Title', component.get('v.TheContent.theMessage.PicTextTitleD__c'));
        component.set('v.PicTextOld_Text', component.get('v.TheContent.theMessage.PicTextMTextD__c'));
    },
    onSingleSelectChangeD: function(component) {
        var selectCmp = component.find("InputSelectSingleD");
        component.set("v.TheContent.theMessage.PicTextTypeD__c", selectCmp.get("v.value"));
    },
    HidePicTextD : function(component, event, helper) {
        component.set('v.ShowPicTextD', false);
    },
    CancelPicTextD : function(component, event, helper) {
        component.set('v.ShowPicTextD', false);
        component.set('v.TheContent.theMessage.PicTextTypeD__c', component.get('v.PicTextOld_Type'));
        component.set('v.TheContent.theMessage.PicTextTitleD__c', component.get('v.PicTextOld_Title'));
        component.set('v.TheContent.theMessage.PicTextMTextD__c', component.get('v.PicTextOld_Text'));
        var selectCmpD = component.find("InputSelectSingleD");
        selectCmpD.set("v.value", component.get('v.PicTextOld_Type'));
    },
    ShowPicTextE : function(component, event, helper) {
        component.set('v.ShowPicTextE', true);
        component.set('v.PicTextOld_Type', component.get('v.TheContent.theMessage.PicTextTypeE__c'));
        component.set('v.PicTextOld_Title', component.get('v.TheContent.theMessage.PicTextTitleE__c'));
        component.set('v.PicTextOld_Text', component.get('v.TheContent.theMessage.PicTextMTextE__c'));
    },
    onSingleSelectChangeE: function(component) {
        var selectCmp = component.find("InputSelectSingleE");
        component.set("v.TheContent.theMessage.PicTextTypeE__c", selectCmp.get("v.value"));
    },
    HidePicTextE : function(component, event, helper) {
        component.set('v.ShowPicTextE', false);
    },
    CancelPicTextE : function(component, event, helper) {
        component.set('v.ShowPicTextE', false);
        component.set('v.TheContent.theMessage.PicTextTypeE__c', component.get('v.PicTextOld_Type'));
        component.set('v.TheContent.theMessage.PicTextTitleE__c', component.get('v.PicTextOld_Title'));
        component.set('v.TheContent.theMessage.PicTextMTextE__c', component.get('v.PicTextOld_Text'));
        var selectCmpE = component.find("InputSelectSingleE");
        selectCmpE.set("v.value", component.get('v.PicTextOld_Type'));
    },
    ShowPicTextF : function(component, event, helper) {
        component.set('v.ShowPicTextF', true);
        component.set('v.PicTextOld_Type', component.get('v.TheContent.theMessage.PicTextTypeF__c'));
        component.set('v.PicTextOld_Title', component.get('v.TheContent.theMessage.PicTextTitleF__c'));
        component.set('v.PicTextOld_Text', component.get('v.TheContent.theMessage.PicTextMTextF__c'));
    },
    onSingleSelectChangeF: function(component) {
        var selectCmp = component.find("InputSelectSingleF");
        component.set("v.TheContent.theMessage.PicTextTypeF__c", selectCmp.get("v.value"));
    },
    HidePicTextF : function(component, event, helper) {
        component.set('v.ShowPicTextF', false);
    },
    CancelPicTextF : function(component, event, helper) {
        component.set('v.ShowPicTextF', false);
        component.set('v.TheContent.theMessage.PicTextTypeF__c', component.get('v.PicTextOld_Type'));
        component.set('v.TheContent.theMessage.PicTextTitleF__c', component.get('v.PicTextOld_Title'));
        component.set('v.TheContent.theMessage.PicTextMTextF__c', component.get('v.PicTextOld_Text'));
        var selectCmpF = component.find("InputSelectSingleF");
        selectCmpF.set("v.value", component.get('v.PicTextOld_Type'));
    },
    onSingleSelectChangeConfirmA: function(component) {
        var selectCmp = component.find("InputSelectSingleConfirmA");
        component.set("v.TheContent.theMessage.ConfirmActionTypeA__c", selectCmp.get("v.value"));
    },
    onSingleSelectChangeConfirmB: function(component) {
        var selectCmp = component.find("InputSelectSingleConfirmB");
        component.set("v.TheContent.theMessage.ConfirmActionTypeB__c", selectCmp.get("v.value"));
    },
    onSingleSelectChangeFlexWidth: function(component) {
        var selectCmp = component.find("InputSelectSingleFlexWidth");
        component.set("v.TheContent.theMessage.FlexSize__c", selectCmp.get("v.value"));
    },
    addNewMessageContent: function(component, event, helper) {
        helper.newMessageContent(component, event);
    },
    removeMessageContent : function(component, event, helper) {
        var returnList = component.get('v.TheContentList');
        var myCount=0;
        for(var i=0; i<returnList.length;i++)
        {
            if(returnList[i].isDeleted__c===false)
            {
                myCount++;
                returnList[i].Index__c = myCount;
            }
        }
        component.set('v.TheContentList', returnList);
        component.set('v.contentCount', myCount);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"success",
            "title": "Success!",
            "message": "已刪除圖卡訊息。"
        });
        toastEvent.fire();
    },
})