import { LightningElement, track, wire, api } from 'lwc';
import getSomeSuggestionsOfProductsByIA from '@salesforce/apex/getSomeSuggestionsOfProductsByIA.getSomeSuggestionsOfProductsByIA';

//import { getRecordId } from 'lightning/uiRecordApi';


export default class LeadInfoTable extends LightningElement {
    @track subject = '';
    @track description = '';
    @track leadData;
    @track error;
    @api recordId;
    @track productsList = [];
    ;

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
    
    handleGetProduct() {
        console.log('Fetching product suggestions...');

        getSomeSuggestionsOfProductsByIA({ leadId: this.recordId })
    .then(result => {
        console.log('this.recordId: ' + result[0]+ result[1]);

        // Clear previous products list
        this.productsList = [];

        // Check if result is not empty
        if (result && Object.keys(result).length > 0) {
            Object.keys(result).forEach(key => {
                this.productsList.push({ name: key, ...result[key] });
            });
            console.log('Product list:', this.productsList);
        } else {
            console.log('No products found for this lead.');
            this.productsList = [];
        }
    })
    .catch(error => {
        console.log('this.recordId: ' + this.recordId);
        this.error = error;
        this.productsList = undefined;
        console.error('Error fetching product suggestions:', error);
    });
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