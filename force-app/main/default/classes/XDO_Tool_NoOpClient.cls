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
 * @date 1/4/2024
 *
 *
 */

 public without sharing class XDO_Tool_NoOpClient extends XDO_Tool_TrackingEventService.XDO_Tool_TrackingEventClient  //NOPMD
 {
     /**
      * Constructors
      */
     public XDO_Tool_NoOpClient() {
     }

     /**
      * initialize: Client initialization
      *
      * @param parameters
      *
      * @return
      */
     public override XDO_Tool_ApiService.Client initialize(Map<String, String> parameters) {
         return this;
     }

     /**
      * transformProfiles: Return
      *
      * @param trackingEvents
      *
      * @return
      */
     public override XDO_Tool_TrackingEventService.XDO_Tool_TrackingEventClient transformEvents(List<XDO_Tool_Tracking_Event__c> trackingEvents) {
         return (XDO_Tool_TrackingEventService.XDO_Tool_TrackingEventClient)this;
     }

     /**
      * processEvents: Return
      *
      * @return
      */
     public override XDO_Tool_TrackingEventService.XDO_Tool_TrackingEventClient importEvents() {
          return (XDO_Tool_TrackingEventService.XDO_Tool_TrackingEventClient)this;
     }

     /**
      * transformProfiles: Return
      *
      * @param trackingEvents
      *
      * @return
      */
     public override XDO_Tool_TrackingEventService.XDO_Tool_TrackingEventClient transformProfiles(List<XDO_Tool_Tracking_Event__c> trackingEvents) {
         return (XDO_Tool_TrackingEventService.XDO_Tool_TrackingEventClient)this;
     }

     /**
      * setProfiles: Return
      *
      * @return
      */
     public override XDO_Tool_TrackingEventService.XDO_Tool_TrackingEventClient setProfiles() {
         return (XDO_Tool_TrackingEventService.XDO_Tool_TrackingEventClient)this;
     }

     /**
      * processResults: Return
      *
      * @param events
      *
      * @return
      */
     public override List<XDO_Tool_Tracking_Event__c> processResults(List<XDO_Tool_Tracking_Event__c> events) {
         return events;
     }
 }