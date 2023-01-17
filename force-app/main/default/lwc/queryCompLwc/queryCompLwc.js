import { LightningElement,api,track,wire} from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getFieldNamesByObject from '@salesforce/apex/queryCompLwcControllerClass.getFieldNamesByObject';
import getallObject from '@salesforce/apex/queryCompLwcControllerClass.getallObject';
import { refreshApex } from '@salesforce/apex';
import { updateRecord } from 'lightning/uiRecordApi';
import queryFromUI from '@salesforce/apex/queryCompLwcControllerClass.queryFromUI';
import updateDataInBulk from '@salesforce/apex/queryCompLwcControllerClass.updateDataInBulk';

const columts=[{
    label: 'View',
    type: 'text',
    initialWidth: 75,
    editable: true,
    typeAttributes:{
        iconName: 'action:preview',
        title: 'Preview',
        variant: 'border-filled',
        alternativeText: 'View'
    }
}];

export default class QueryCompLwc extends LightningElement {

    //modal popup input values
    @track inPutValueModal ;
    @track modalSelectedField ;

    @track isLoading=false;
    @api sortedDirection = 'asc';
    @api sortedBy = 'Name';
    @api searchKey = '';
    result;
    @track allSelectedRows = [];
    @track page = 1; 
    @track items = []; 
    @track data = []; 
    @track columns; 
    @track startingRecord = 1;
    @track endingRecord = 0; 
    @track pageSize=5; 
    @track totalRecountCount = 0;
    @track totalPage = 0;
    isPageChanged = false;
    initialLoad = true;
    mapoppNameVsOpp = new Map();;

    @track modalinputTpe;
    @track isShowModal = false;
    @track massUpdate=false;
    
    @track  draftValues = [];
    @track DataTableResponseWrappper;
    @track finalSObjectDataList;

    @track selectedObject;
    @track feildData=[];
    @track objectList;
    @track operators;
    @track optionValues = [];
    @track fieldSelected;
    @track selctedOpretorfor;
    @track selectedfeild;
    @track rows=[{index:0,selectedField: '' , operators: [],selectedOpetor:'' ,showInput:true , inputValue:''}]

    @track mulFeild;
    @track inPutValueSelecte;
    @track inputType;
    @track showInput = false;
    @track myArray=[];
    @track withOutComm;
    @track withOutl;
    @track withOutR;
    //Maps
    @track customSettingData;
    @track fieldTypeByApiName ;
    @track fieldLabelNameByApiName;
    //Store handler value
    @track opNmae;
    @track opValue;
    @track inPutName;
    @track inPutValue;

    //datafrom query
    @track queryDataRsult;
    @track columns =columts;
    //Value Storing Attributes
    
    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }

    objecthandleChange(event) {
        this.selectedObject = event.detail.value;
       alert(this.selectedObject);
    }


    
    //getting All Objects from connectdCallback
    connectedCallback(){
        debugger;
        getallObject()
        .then(data=>{
            console.log(`this is result from cCback ${data}`);
            let option = [];
            data.forEach(d => {
                option.push({
                    label: d,
                    value: d,
                })
            });
            this.objectList = option;
        })
        .catch(error=>{
            console.log(`this is result from cCback ${error}`);
        })
    }

    // calling Apex wrapper method retuning three maps containting 
        //fieldLabelNameByApiName ==  feild Lable And Api name
        //fieldTypeByApiName == feild Api name and type value 
        //customSettingData == custing Setting with String  value
    @wire(getFieldNamesByObject,{ObjName:'$selectedObject'})
    wireResponse({error,data}){
        debugger;
        if(data){
        this.fieldLabelNameByApiName  = data[0].fieldLabelNameByApiName;
        this.fieldTypeByApiName = data[0].fieldTypeByApiName;
        this.customSettingData = data[0].customSettingData;
        let options = [];
        for (var key in this.fieldLabelNameByApiName) {
            options.push({ label: key, value: this.fieldLabelNameByApiName[key]  });
        }
        this.feildData = options;

        let option
        for(var key in this.customSettingData){
            
                //option.push({lable:this.fieldSelected, value:[key] });
        }
        this.operators=option;
       // console.log('typeof this.feildData',typeof this.feildData);
        }
        
        if(error){
            console.log(` error from  getall feildname ${error}`)
        }
        let feildType=[];   

    }


    handlerChange(event){
        debugger;
        
        let value = event.target.value;
        //value = value.toLowerCase();
        this.selectedfeild=value;
        
        let fieldType = this.fieldTypeByApiName[value.toLowerCase()].toLowerCase();
        let csOpList=[];
       
        //operators = '';
        if(fieldType == 'string' || fieldType == 'textarea' || fieldType == 'text'  || fieldType == 'email' || fieldType == 'id' ){
            this.customSettingData['Text'].forEach(e=>{
                csOpList.push({
                    label:e,
                    value:e
                })
            })
              this.inputType = 'text';
              this.showInput = true;
              this.myArray=csOpList;
        }

        if(fieldType == 'number' || fieldType == 'blob' ||  fieldType == 'reference' || fieldType == 'phone' || fieldType == 'double'){
            this.customSettingData['Number'].forEach(e=>{
                csOpList.push({
                    label:e,
                    value:e
                })
            })
            this.inputType = 'number';
            this.showInput = true;
            this.myArray=csOpList;
        }


        if(fieldType == 'date' || fieldType == 'datetime' || fieldType == 'date'){
            this.customSettingData['Date'].forEach(e=>{
                csOpList.push({
                    label:e,
                    value:e
                })
            })
              this.inputType = 'date';
              this.showInput = true;
              this.myArray=csOpList;
        }

        if(fieldType == 'checkbox' || fieldType == 'boolean'){
            this.customSettingData['Checkbox'].forEach(e=>{
                csOpList.push({
                    label:e,
                    value:e
                })
            })
              this.inputType = 'checkbox';
              this.showInput = true;
              this.myArray=csOpList;
        }

        //Using the Second map to get the operators

        //let selectedOpe=event.detail.value;
        let fieldName=event.target.name;
        let index=parseInt(event.currentTarget.dataset.id);
        this.rows[index].operators = csOpList;
      // this.rows[index].selectFeildType = inPutValue;
       this.rows[index].selectFeildType=this.inputType;
       this.rows[index].selectedField=this.selectedfeild;

    }
    handleOperaote(event){
        debugger;
        this.opNmae=event.target.name;
        this.opValue=event.detail.value;
        alert(JSON.stringify(this.opValue));
        let index = event.currentTarget.dataset.id;
        this.rows[index].selectedOpetor=this.opValue;

    }
    handlInputValue(event){
        //debugger;
        this.inPutName=event.target.name;
        this.inPutValue=event.detail.value;
        let index = event.currentTarget.dataset.id;
        this.rows[index].inputValue=this.inPutValue;
        // alert(this.inPutValue);
    }
    handBtnAction(event){
        debugger;
        let action = event.target.name;
        let index = event.currentTarget.dataset.id;
        
        
        if(action=='plus'){
            this.rows[index].field = this.selectedfeild;
           // this.rows[index].operators = this.opValue;
            this.rows[index].inputValues = this.inPutValue;
            //add row
            let newObj = {...this.rows[index]};
            newObj.index=this.rows.length

          
           
           
            this.rows.push(newObj);
            this.showInput = false ;
            alert(this.rows.length);
        }
        if(action=='minus'){
            //remove Row
            this.rows=this.rows.filter(item=>item.index !=index)
            alert(this.rows.length);
        }
    }

    queyBtn(){
        debugger;
        this.isLoading=true;
        var wrapperData = [];

        for (let i = 0; i < this.rows.length; i++) {
            let filterObj = {selectedField: this.rows[i].selectedField, selectedOpetor:this.rows[i].selectedOpetor, inputValue:this.rows[i].inputValue,multiSelectefFiledList:this.mulFeild};
            wrapperData.push(filterObj);
            filterObj = {selectedField: '', selectedOpetor:'', inputValue:''};
          }
        console.log('wrapperData',wrapperData);
        queryFromUI({FilteredCriterias: wrapperData,ObjectName:this.selectedObject})
        .then(data=>{
            let sObjectRelatedFieldListValues = [];
            for (let row of data.lstDataTableData) 
            {
                 const finalSobjectRow = {}
                 let rowIndexes = Object.keys(row); 
                 rowIndexes.forEach((rowIndex) => 
                 {
                     const relatedFieldValue = row[rowIndex];
                     if(relatedFieldValue.constructor === Object)
                     {
                         this._flattenTransformation(relatedFieldValue, finalSobjectRow, rowIndex)        
                     }
                     else
                     {
                         finalSobjectRow[rowIndex] = relatedFieldValue;
                     }
                     
                 });
                 sObjectRelatedFieldListValues.push(finalSobjectRow);
             }
             this.DataTableResponseWrappper = data;
             this.finalSObjectDataList = sObjectRelatedFieldListValues;
             this.processRecords(sObjectRelatedFieldListValues);
             this.isLoading=false;
           
        })
        .catch(error=>{
        })
    }
    _flattenTransformation = (fieldValue, finalSobjectRow, fieldName) => 
    {        
        let rowIndexes = Object.keys(fieldValue);
        rowIndexes.forEach((key) => 
        {
            let finalKey = fieldName + '.'+ key;
            finalSobjectRow[finalKey] = fieldValue[key];
        })
    }


    processRecords(data){
        this.items = data;
            this.totalRecountCount = data.length; 
            this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize); 
            
            this.data = this.items.slice(0,this.pageSize); 
            this.endingRecord = this.pageSize;
            //this.columns = columns;
    }
    //clicking on previous button this method will be called
    previousHandler() {
        debugger;
        this.isPageChanged = true;
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
            selectedIds.push(this.allSelectedRows[i].Id);
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;
    }

    nextHandler() {
        debugger;
        this.isPageChanged = true;
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);            
        }
          var selectedIds = [];
          for(var i=0; i<this.allSelectedRows.length;i++){
            selectedIds.push(this.allSelectedRows[i].Id);
          }
        this.template.querySelector(
            '[data-id="table"]'
          ).selectedRows = selectedIds;
    }

    displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.pageSize) ;
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                            ? this.totalRecountCount : this.endingRecord; 

        this.data = this.items.slice(this.startingRecord, this.endingRecord);
        this.startingRecord = this.startingRecord + 1;
    }  

    onRowSelection(event){
        if(!this.isPageChanged || this.initialLoad){
            if(this.initialLoad) this.initialLoad = false;
            this.processSelectedRows(event.detail.selectedRows);
        }else{
            this.isPageChanged = false;
            this.initialLoad =true;
        }
        
    }

    processSelectedRows(selectedOpps){
        var newMap = new Map();
        for(var i=0; i<selectedOpps.length;i++){
            if(!this.allSelectedRows.includes(selectedOpps[i])){
                this.allSelectedRows.push(selectedOpps[i]);
            }
            this.mapoppNameVsOpp.set(selectedOpps[i].Name, selectedOpps[i]);
            newMap.set(selectedOpps[i].Name, selectedOpps[i]);
        }
        for(let [key,value] of this.mapoppNameVsOpp.entries()){
            if(newMap.size<=0 || (!newMap.has(key) && this.initialLoad)){
                const index = this.allSelectedRows.indexOf(value);
                if (index > -1) {
                    this.allSelectedRows.splice(index, 1); 
                }
            }
        }
    }

    // inline Edit from here, below codes for that 
     async  handleSave(event){
        debugger;
        const records = event.detail.draftValues.slice().map((draftValue) => {
            const fields = Object.assign({}, draftValue);
            return { fields };
        });

        this.draftValues = [];

        try {

            const recordUpdatePromises = records.map((record) =>
                updateRecord(record)
            );
            
            await Promise.all(recordUpdatePromises);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Contacts updated',
                    variant: 'success'
                })
            );
            await refreshApex(this.data);
            this.draftValues = [];
        } catch (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading contacts',
                    message: error.body.message,
                    variant: 'error'
                })
            );
            
        }
    }

    //handling massupdate here for sungle feild and parameter
    massUpdateBTN(){
    debugger;
    this.massUpdate = true;
    this.isShowModal = true;
    }

    processDataInBulk(){
    debugger;
    this.inPutValueModal;
    this.modalSelectedField;
    var selIds = [];

    for (let i = 0; i < this.allSelectedRows.length; i++) {
            selIds.push(this.allSelectedRows[i].Id);
    }

    updateDataInBulk({objectName: this.selectedObject ,Fieldname:this.modalSelectedField,inputValue : this.inPutValueModal,selectedRecIds : selIds})
        .then(data=>{
            console.log('Coming Here For Bulk..');
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'records updated',
                    variant: 'success'
                })
            );
            console.log(data);
            this.isShowModal=false;
            this.massUpdate = false;
            this.queryFromUI();
        })
        .catch(error=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or reloading records',
                    message: error.body.message,
                    variant: 'error'
                })
            );
        })
    }

    //cancel massUpdate modal
    handleCancel(){
        this.isShowModal = false;
    }

    handleInputValuemodal(event){
        debugger;
        this.inPutValueModal = event.target.value;
    }
    
    handlerChangeModal(event){
        debugger;
        this.modalSelectedField = event.target.value;
        let modalFeildType =  this.fieldTypeByApiName[this.modalSelectedField.toLowerCase()].toLowerCase();
        if(modalFeildType== 'date' || modalFeildType == 'datetime' || modalFeildType == 'DATE'){
            this.modalinputTpe='date';
        }
        if(modalFeildType == 'checkbox' || modalFeildType == 'boolean'){
            this.modalinputTpe='checkbox';
        }
        if(modalFeildType== 'string' || modalFeildType == 'text' || modalFeildType == 'textarea' || modalFeildType == 'email' || modalFeildType == 'id'){
            this.modalinputTpe='string';
        }

    }

    //dual List box to Show multiple field for selected Onject...
    DualListBoxhandleChange(event){
        debugger;
        const selectedOptionsList = event.detail.value;
        this.mulFeild=selectedOptionsList
       // console.log('Selected Options are ' + JSON.stringify( selectedOptionsList ) );
        alert('Selected Options are ' + JSON.stringify( selectedOptionsList ) );
       // this.updatedCons = selectedOptionsList;
    }


    get numberOfpage() {
        return [
            { label: '5', value: '5' },
            { label: '10', value: '10' },
            { label: '20', value: '20' },
            { label: '50', value: '50' },
            { label: '100', value: '100' },
            { label: '150', value: '150' },
            { label: '200', value: '200' },
        ];
    }


    numberOfpageHandler(event) {
        debugger;
        const noOfrecToView = event.detail.value;
        const intValue=parseInt(noOfrecToView);
        this.pageSize=intValue;

    }

    

    
}