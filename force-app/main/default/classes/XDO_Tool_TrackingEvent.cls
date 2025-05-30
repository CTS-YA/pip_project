/*
 * Copyright (c) 2020, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */


/**
 * @author Paul Lucas
 * @company       Salesforce
 *
 * @date 17/1/2024
 *
 * TODO:
 */

public without sharing virtual class XDO_Tool_TrackingEvent //NOPMD
{
    public enum TRACKING_EVENT_TYPE {
        Reporting,
        Product,
        Monitoring
    }

    public enum TRACKING_PROPERTY {
        action,
        asset_identifier,
        once,
        page,
        source,
        type,
        value
    }

    public static String org_identifier = [
            SELECT Identifier__c
            FROM QLabs__mdt
            WHERE DeveloperName = 'Org_Identifier'
            LIMIT 1
    ]?.Identifier__c;

    @AuraEnabled
    @InvocableVariable(Label='Action' Description='An annotation to describe the "action" that occurred at the time of the event during the flow' Required=true)
    public String action;

    @AuraEnabled
    @InvocableVariable(Label='Asset Identifier' Description='The name of your flow appended with a versionFollow the convention of pascal case followed by an underscore and then a version, eg. IdentityVerificationFlow_v1' Required=true)
    public String asset_identifier;

    @AuraEnabled
    @InvocableVariable(Label='Event' Description='Tracking event. Reporting => Conversion. Product => Error, Exception. Monitoring => Ping.' Required=true)
    public String event;

    @AuraEnabled
    @InvocableVariable(Label='Once?' Description='Only track this event once?' Required=true)
    public Boolean once = false;

    @AuraEnabled
    @InvocableVariable(Label='Properties' Description='Tracking event properties' Required=true)
    public List<XDO_Tool_TrackingEventProperty> properties;

    public String type;

//    @AuraEnabled
//    @InvocableVariable(Label='result' Description='Tracking event result' Required=false)
//    public String result;

    /**
     * Constructors
     */
    public XDO_Tool_TrackingEvent() {
    }

    protected XDO_Tool_TrackingEvent(TRACKING_EVENT_TYPE type, String event) {
        this.properties = new List<XDO_Tool_TrackingEventProperty>();
        setType(type);
        setEvent(event);
    }

    /**
     * setAction: Set action property
     *
     * @param value
     *
     * @return
     */
    public XDO_Tool_TrackingEvent setAction(String value) {
        this.action = value;
        this.addProperty(TRACKING_PROPERTY.action.name(), value);

        return this;
    }

    /**
     * setAssetIdentifier: Set asset identifier property
     *
     * @param value
     *
     * @return
     */
    public XDO_Tool_TrackingEvent setAssetIdentifier(String value) {
        this.asset_identifier = value;
        this.addProperty(TRACKING_PROPERTY.asset_identifier.name(), value);

        return this;
    }

    /**
     * setEvent: Set event property
     *
     * @param value
     *
     * @return
     */
    public XDO_Tool_TrackingEvent setEvent(String value) {
        this.event = value;

        return this;
    }

    /**
     * setOnce: Set once property
     *
     * @param value
     *
     * @return
     */
    public XDO_Tool_TrackingEvent setOnce(Boolean value) {
        this.once = value;

        return this;
    }

    /**
     * setPage: Set page property
     *
     * @param value
     *
     * @return
     */
    public XDO_Tool_TrackingEvent setPage(String value) {
        this.addProperty(TRACKING_PROPERTY.page.name(), value);

        return this;
    }

    /**
     * setSource: Set source property
     *
     * @param value
     *
     * @return
     */
    public XDO_Tool_TrackingEvent setSource(String value) {
        this.addProperty(TRACKING_PROPERTY.source.name(), value);

        return this;
    }

    /**
     * setType: Set type property
     *
     * @param value
     *
     * @return
     */
    public XDO_Tool_TrackingEvent setType(TRACKING_EVENT_TYPE value) {
        this.type = value.name();
        this.addProperty(TRACKING_PROPERTY.type.name(), value.name());

        return this;
    }

    /**
     * setValue: Set value property
     *
     * @param value
     *
     * @return
     */
    public XDO_Tool_TrackingEvent setValue(String value) {
        this.addProperty(TRACKING_PROPERTY.value.name(), value);

        return this;
    }

    /**
     * addProperty: Add a single property
     *
     * @param name
     * @param value
     *
     * @return
     */
    public XDO_Tool_TrackingEvent addProperty(String name, String value) {
        addProperties(new Map<String, String>{
                name => value
        });

        return this;
    }

    /**
     * addProperties: Add a collection of properties
     *
     * @param properties
     *
     * @return
     */
    public XDO_Tool_TrackingEvent addProperties(Map<String, String> properties) {
        for (String key : properties.keySet()) {
            this.properties.add(new XDO_Tool_TrackingEventProperty(key, properties.get(key)));
        }

        return this;
    }

    /**
     * getPropertyValue: Return a property value given a property name
     *
     * @param name
     *
     * @return
     */
    public String getPropertyValue(String name) {
        for (XDO_Tool_TrackingEventProperty property : this.properties) {
            if (property.name == name) {
                return property.value;
            }
        }

        return null;
    }

    /**
     * serialize: Serialize the object
     *
     * @return
     */
    public String serialize() {
        return JSON.serialize(this);
    }

    /**
     * publish: Publish a XDO_Tool_Platform_Tracking_Event__e
     */
    public void publish() {
        EventBus.publish(new XDO_Tool_Platform_Tracking_Event__e(
                Action__c = this.action,
                Asset_Identifier__c = this.asset_identifier,
                Event__c = this.event,
                Once__c = Boolean.valueOf(this.once),
                Payload__c = serialize(),
                Type__c = this.type,
                User_Id__c = UserInfo.getUserId()
        ));
    }

    /**
     * Contextual metadata for event messages
     */
    public class Context {
        public Datetime created;
        public Long createdTime {
            get {
                return this.created.getTime();
            }
        }
        public String guid;
        public String email;

        public String orgId {
            get {
                return UserInfo.getOrganizationId();
            }
        }

        public String orgType {
            get {
                return ORG_IDENTIFIER;
            }
        }

        public Context() {
        }

        public Context(XDO_Tool_Tracking_Event__c event) {
            this.guid = event.Unique_Id__c;
            this.email = event.Email__c;
            this.created = event.CreatedDate;
        }

        public String serialize() {
            return JSON.serialize(this);
        }
    }
}