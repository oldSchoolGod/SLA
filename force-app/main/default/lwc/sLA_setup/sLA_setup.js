import { LightningElement, wire,track, api } from 'lwc';

import getPicklistValuesOfCases from '@salesforce/apex/schemaOnCase.getCaseStatusPicklistValue';

import Apex_Method_One_Ref from "@salesforce/apex/schemaOnCase.savingRecords";

import getEmailTemplateValues from "@salesforce/apex/schemaOnCase.getAllEmailTemplateRecords";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class SLA_setup extends LightningElement {
 @track emailtemps= [];
 selectedVal = [];

 @track caseStatusvalues = [];
@api picklistValue = 'inProgress';
@api isManagerOrHierarchy ;
@api isBusiness;
@api slaIntervalTimes;
@api emailTemplates;
isHierarchyVisible =true ;
isManagerVisible = true ;
isBusinessVisible= false ;
isslaIntervalTimesVisible = false ;
isemailTemplatesVisible = false ;
isFieldSet =true;
isFaq =true ;
error ;
isSaveVisible = false;
iscomboBoxVisible = false;
isSaveVisibleforhierarchy = false;

activeSections = [];
   activeSectionsMessage = '';

handleBusinessChange(event){
   this.isBusiness = event.target.checked;
}

handleSlaIntervalChange(event){
   this.slaIntervalTimes = event.target.value;
   console.log(event.target.value);
   console.log('length :'+this.slaIntervalTimes.length);

}

handleEmailTemplatesChange(event){
   this.emailTemplates = event.target.value;
   console.log(event.target.value);
   
}

handelSave(event){
   console.log('this.selectedVal :'+this.selectedVal);
   console.log('this.isManagerOrHierarchy :'+this.isManagerOrHierarchy);
   console.log('this.isBusiness :'+this.isBusiness);
   console.log('this.slaTiminterval :'+this.slaIntervalTimes);
   console.log('statusVAlue :'+this.picklistValue);

  /* let calculating = this.slaIntervalTimes;
   let count=0;
   if(this.slaIntervalTimes ==null){
      console.log('sla time interval is empty');
      const event = new ShowToastEvent({
         title : 'Error',
         message : 'Sale Time Interval is empty',
         variant : 'error'
      });
      this.dispatchEvent(event);
   }
   else{
      for(var i =0 ; i<calculating.length ; i++){
      console.log('49');
      let indexValue = calculating.charAt(i); 
      if(indexValue == ','){
      count++;
      }
   }
   console.log('count value :'+count);

   if(this.slaIntervalTimes != null && (count == 0 || count == 3)){
      const event = new ShowToastEvent({
         title: 'SLA Time Interaval is valid ',
         message: 'you may proceed further',
         variant: 'success'
      });
      this.dispatchEvent(event);     
   }
   else {
      const event = new ShowToastEvent({
         title : 'Error',
         message : 'Sale Time Interval is not valid ',
         variant : 'error'
      });
      this.dispatchEvent(event);
   }
}  */
   
   

  Apex_Method_One_Ref({ 
      isManagerOrHierarchy : this.isManagerOrHierarchy, 
      isBusiness : this.isBusiness, 
     // emailTemplates :  JSON.stringify(this.selectedVal),
     emailTemplates :  this.selectedVal,
      slaIntervalTimes : this.slaIntervalTimes,
      picklistValue : this.picklistValue

   })
   .then(result => {
      const event = new ShowToastEvent({
            title: 'SLA setup has been done ',
            message: 'Sale configuration record has been created ',
            variant: 'success'
      });
      this.dispatchEvent(event);
   })
   .catch(error => {
      const event = new ShowToastEvent({
            title : 'Error',
            message : 'Sale configuration record has not been created ',
            variant : 'error'
      });
      this.dispatchEvent(event);
   });  

}

buttonForManager(event){
   console.log('buttonForManager');
   console.log(' making true ');
   
   this.isFaq = false ;
   this.isManagerOrHierarchy = 'manager';
   console.log('line 39 isManagered :'+this.isManagerOrHierarchy);
   this.isBusinessVisible= true ;
   this.isslaIntervalTimesVisible = true ;
   this.isemailTemplatesVisible = true ;
   this.isSaveVisible= true;
   this.iscomboBoxVisible = true;
   this.isSaveVisibleforhierarchy=false;
   this.isFieldSet = true;
   
   
}
buttonForHierarchy(event){
this.isManagerOrHierarchy = 'Hierarchy';
this.isFaq = false ;
   console.log('line 46 isManagered :'+this.isManagerOrHierarchy);
   this.isBusinessVisible= false ;
   this.isslaIntervalTimesVisible = false ;
   this.isemailTemplatesVisible = false ;
   this.isSaveVisible= true;
   this.iscomboBoxVisible = true;
   this.isSaveVisibleforhierarchy=false;
}

@wire (getPicklistValuesOfCases ,{sObjectName : 'Case' ,fieldApiName : 'Status'})
wiregetpicklist({data,error}){
   if (data) {
      var tempmap = [];
      for(var key in data){
      tempmap.push({label : key , value : data[key]});
      }
      this.caseStatusvalues = tempmap;
      console.log('this.caseStatusvalues line 157 : '+JSON.stringify(this.caseStatusvalues));
      this.error = undefined;
   } else if (error) {
      this.error = error;
   
   }
}

handleChange(event){
   this.picklistValue = event.detail.value;
   console.log('picklistValue ' +this.picklistValue);
}

handleSectionToggle(event) {
   const openSections = event.detail.openSections;

   if (openSections.length === 0) {
         this.activeSectionsMessage = 'All sections are closed';
   } else {
         this.activeSectionsMessage =
            'Open sections: ' + openSections.join(', ');
   }
}
faqbutton(event){
this.isFaq =true ;
this.isFieldSet = false;
}
connectedCallback(event){
   console.log('line 188 ');
   // call apex method 

   getEmailTemplateValues()
   .then(result => {
      
      console.log(JSON.stringify(result));
      var tempmap = [];
      var resultArray = result;
      for(var key in resultArray){
         tempmap.push({label : key , value : resultArray[key]});
        } 
        this.emailtemps = tempmap;
        console.log('this.emailtemps line 202'+ JSON.stringify(this.emailtemps));  
     
   })
   .catch(error => {
      console.log('no data');
   }); 

   console.log('list values'+this.emailtemps);

}

selectedValue(e) {
   this.selectedVal = e.detail.value;
   console.log('line 219'+this.selectedVal);
}

home(){
   this.isFaq="true";
   this.isFieldSet = false;
   this.iscomboBoxVisible=false;
   this.isslaIntervalTimesVisible=false;
 


}


}