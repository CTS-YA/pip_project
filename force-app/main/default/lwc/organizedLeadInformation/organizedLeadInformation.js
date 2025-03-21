import { LightningElement, track, wire, api } from 'lwc';
import leadInformationGetter from '@salesforce/apex/LeadInformationGetter.leadInformationGetter';
//import { getRecordId } from 'lightning/uiRecordApi';


export default class LeadInfoTable extends LightningElement {
    @track subject = '';
    @track description = '';
    @track leadData;
    @track error;
    @api recordId;

    /*@wire(getRecordId)
    wiredRecordId({ error, data }) {
        if (data) {
            this.recordId = data;
        } else if (error) {
            console.error('Error retrieving record ID:', error);
        }
    }*/
    columns = [
        { label: 'Key', fieldName: 'key' },
        { label: 'Value', fieldName: 'value' }
    ];

    handleSubjectChange(event) {
        this.subject = event.target.value;
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handleGetLeadInfo() {
        console.log('this.recordId: '+ this.recordId);

        leadInformationGetter({ leadId: this.recordId})
            .then(result => {
                //console.log('leadId: '+ leadId);
                this.leadData = Object.entries(result).map(([key, value]) => ({ key, value }));
                this.error = undefined;
                console.log('passer2');
            })
            .catch(error => {
                this.error = error;
                this.leadData = undefined;
                console.log('passer3');

            });
    }
}