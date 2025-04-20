trigger CaseAfterInsert on Case (after insert) {
    CreateLeadFromEmailHandler.handleCaseInsert(Trigger.new);
}