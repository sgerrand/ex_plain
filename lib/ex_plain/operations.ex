defmodule ExPlain.Operations do
  @moduledoc false

  # ---------------------------------------------------------------------------
  # Shared field selections (inlined into queries — no GraphQL fragment syntax)
  # ---------------------------------------------------------------------------

  @dt "iso8601\nunixTimestamp"

  @page_info """
  hasNextPage
  hasPreviousPage
  startCursor
  endCursor
  """

  @mutation_error """
  message
  type
  code
  fields {
    field
    message
    type
  }
  """

  # Actor (full: CustomerActor | DeletedCustomerActor | MachineUserActor | SystemActor | UserActor)
  @actor """
  ... on UserActor { __typename userId }
  ... on CustomerActor { __typename customerId }
  ... on SystemActor { __typename }
  ... on MachineUserActor { __typename machineUserId }
  ... on DeletedCustomerActor { __typename customerId }
  """

  # InternalActor (no customer variants)
  @internal_actor """
  ... on UserActor { __typename userId }
  ... on SystemActor { __typename }
  ... on MachineUserActor { __typename machineUserId }
  """

  # ThreadAssignee (User | MachineUser | System) — different types from Actor
  @thread_assignee """
  ... on User {
    __typename
    id
    fullName
    publicName
    email
    updatedAt { #{@dt} }
  }
  ... on MachineUser {
    __typename
    id
    fullName
    publicName
  }
  ... on System { __typename }
  """

  @thread_status_detail """
  ... on ThreadStatusDetailCreated {
    __typename
    createdAt { #{@dt} }
  }
  ... on ThreadStatusDetailNewReply {
    __typename
    statusChangedAt { #{@dt} }
  }
  ... on ThreadStatusDetailInProgress {
    __typename
    statusChangedAt { #{@dt} }
  }
  ... on ThreadStatusDetailThreadDiscussionResolved {
    __typename
    threadDiscussionId
    statusChangedAt { #{@dt} }
  }
  ... on ThreadStatusDetailThreadLinkUpdated {
    __typename
    linearIssueId
    statusChangedAt { #{@dt} }
  }
  ... on ThreadStatusDetailWaitingForCustomer {
    __typename
    statusChangedAt { #{@dt} }
  }
  ... on ThreadStatusDetailWaitingForDuration {
    __typename
    statusChangedAt { #{@dt} }
    waitingUntil { #{@dt} }
  }
  ... on ThreadStatusDetailDoneManuallySet {
    __typename
    statusChangedAt { #{@dt} }
  }
  ... on ThreadStatusDetailDoneAutomaticallySet {
    __typename
    afterSeconds
    statusChangedAt { #{@dt} }
  }
  ... on ThreadStatusDetailIgnored {
    __typename
    statusChangedAt { #{@dt} }
  }
  """

  @label_type_fields """
  id name icon isArchived
  archivedAt { #{@dt} }
  archivedBy { #{@internal_actor} }
  createdAt { #{@dt} }
  createdBy { #{@internal_actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@internal_actor} }
  """

  @label_fields """
  id
  labelType { #{@label_type_fields} }
  createdAt { #{@dt} }
  createdBy { #{@actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@actor} }
  """

  @tier_fields """
  id name externalId defaultThreadPriority
  createdAt { #{@dt} }
  createdBy { #{@internal_actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@internal_actor} }
  """

  @company_fields """
  id name domainName
  createdAt { #{@dt} }
  createdBy { #{@internal_actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@internal_actor} }
  """

  @tenant_fields """
  id name externalId url
  tier { #{@tier_fields} }
  createdAt { #{@dt} }
  createdBy { #{@internal_actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@internal_actor} }
  """

  @customer_fields """
  id fullName shortName externalId
  email { email isVerified verifiedAt { #{@dt} } }
  company { #{@company_fields} }
  updatedAt { #{@dt} }
  createdAt { #{@dt} }
  createdBy { #{@internal_actor} }
  markedAsSpamAt { #{@dt} }
  """

  @thread_field_fields """
  id key type threadId stringValue booleanValue isAiGenerated
  createdAt { #{@dt} }
  createdBy { #{@internal_actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@internal_actor} }
  """

  @thread_fields """
  id ref externalId
  customer { id }
  status
  statusDetail { #{@thread_status_detail} }
  statusChangedAt { #{@dt} }
  title description previewText priority
  tenant { #{@tenant_fields} }
  labels { #{@label_fields} }
  threadFields { #{@thread_field_fields} }
  assignedAt { #{@dt} }
  assignedTo { #{@thread_assignee} }
  lockedAt { #{@dt} }
  createdAt { #{@dt} }
  createdBy { #{@actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@actor} }
  """

  @user_fields """
  id fullName publicName email
  updatedAt { #{@dt} }
  """

  @customer_event_fields """
  id customerId title
  createdAt { #{@dt} }
  createdBy { #{@actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@actor} }
  """

  @thread_event_fields """
  id threadId customerId title
  createdAt { #{@dt} }
  createdBy { #{@actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@actor} }
  """

  @webhook_target_fields """
  id url isEnabled description
  createdAt { #{@dt} }
  createdBy { #{@actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@actor} }
  eventSubscriptions { __typename eventType }
  """

  @note_fields "id markdown text"

  @chat_fields """
  id text
  attachments { id }
  createdAt { #{@dt} }
  updatedAt { #{@dt} }
  """

  @customer_group_fields "id key name color externalId createdAt { #{@dt} } updatedAt { #{@dt} }"

  @company_tier_membership_fields """
  __typename id
  company { #{@company_fields} }
  tier { #{@tier_fields} }
  createdAt { #{@dt} }
  createdBy { #{@internal_actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@internal_actor} }
  """

  @tenant_tier_membership_fields """
  __typename id
  tenant { #{@tenant_fields} }
  tier { #{@tier_fields} }
  createdAt { #{@dt} }
  createdBy { #{@internal_actor} }
  updatedAt { #{@dt} }
  updatedBy { #{@internal_actor} }
  """

  # ---------------------------------------------------------------------------
  # Customer queries
  # ---------------------------------------------------------------------------

  @doc false
  def customers do
    """
    query customers($filters: CustomersFilter, $sortBy: CustomersSort,
                    $first: Int, $after: String, $last: Int, $before: String) {
      customers(filters: $filters, sortBy: $sortBy,
                first: $first, after: $after, last: $last, before: $before) {
        edges { node { #{@customer_fields} } }
        pageInfo { #{@page_info} }
        totalCount
      }
    }
    """
  end

  @doc false
  def customer_by_id do
    """
    query customerById($customerId: ID!) {
      customer(customerId: $customerId) { #{@customer_fields} }
    }
    """
  end

  @doc false
  def customer_by_email do
    """
    query customerByEmail($email: String!) {
      customerByEmail(email: $email) { #{@customer_fields} }
    }
    """
  end

  @doc false
  def customer_by_external_id do
    """
    query customerByExternalId($externalId: ID!) {
      customerByExternalId(externalId: $externalId) { #{@customer_fields} }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Customer mutations
  # ---------------------------------------------------------------------------

  @doc false
  def upsert_customer do
    """
    mutation upsertCustomer($input: UpsertCustomerInput!) {
      upsertCustomer(input: $input) {
        result
        customer { #{@customer_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def delete_customer do
    """
    mutation deleteCustomer($input: DeleteCustomerInput!) {
      deleteCustomer(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def update_customer_company do
    """
    mutation updateCustomerCompany($input: UpdateCustomerCompanyInput!) {
      updateCustomerCompany(input: $input) {
        customer { #{@customer_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Customer group queries
  # ---------------------------------------------------------------------------

  @doc false
  def customer_groups do
    """
    query customerGroups($first: Int, $after: String, $last: Int, $before: String) {
      customerGroups(first: $first, after: $after, last: $last, before: $before) {
        edges { node { #{@customer_group_fields} } }
        pageInfo { #{@page_info} }
      }
    }
    """
  end

  @doc false
  def customer_group_by_id do
    """
    query customerGroupById($customerGroupId: ID!) {
      customerGroup(customerGroupId: $customerGroupId) { #{@customer_group_fields} }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Customer group mutations
  # ---------------------------------------------------------------------------

  @doc false
  def add_customer_to_customer_groups do
    """
    mutation addCustomerToCustomerGroups($input: AddCustomerToCustomerGroupsInput!) {
      addCustomerToCustomerGroups(input: $input) {
        customerGroupMemberships {
          id
          customerGroup { #{@customer_group_fields} }
          createdAt { #{@dt} }
          updatedAt { #{@dt} }
        }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def remove_customer_from_customer_groups do
    """
    mutation removeCustomerFromCustomerGroups($input: RemoveCustomerFromCustomerGroupsInput!) {
      removeCustomerFromCustomerGroups(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Thread queries
  # ---------------------------------------------------------------------------

  @doc false
  def threads do
    """
    query threads($filters: ThreadsFilter, $sortBy: ThreadsSort,
                  $first: Int, $after: String, $last: Int, $before: String) {
      threads(filters: $filters, sortBy: $sortBy,
              first: $first, after: $after, last: $last, before: $before) {
        edges { cursor node { #{@thread_fields} } }
        pageInfo { #{@page_info} }
      }
    }
    """
  end

  @doc false
  def thread_by_id do
    """
    query thread($threadId: ID!) {
      thread(threadId: $threadId) { #{@thread_fields} }
    }
    """
  end

  @doc false
  def thread_by_ref do
    """
    query threadByRef($ref: String!) {
      threadByRef(ref: $ref) { #{@thread_fields} }
    }
    """
  end

  @doc false
  def thread_by_external_id do
    """
    query threadByExternalId($customerId: ID!, $externalId: ID!) {
      threadByExternalId(customerId: $customerId, externalId: $externalId) { #{@thread_fields} }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Thread mutations
  # ---------------------------------------------------------------------------

  @doc false
  def create_thread do
    """
    mutation createThread($input: CreateThreadInput!) {
      createThread(input: $input) {
        thread { #{@thread_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def assign_thread do
    """
    mutation assignThread($input: AssignThreadInput!) {
      assignThread(input: $input) {
        thread { #{@thread_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def unassign_thread do
    """
    mutation unassignThread($input: UnassignThreadInput!) {
      unassignThread(input: $input) {
        thread { #{@thread_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def change_thread_priority do
    """
    mutation changeThreadPriority($input: ChangeThreadPriorityInput!) {
      changeThreadPriority(input: $input) {
        thread { #{@thread_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def update_thread_tenant do
    """
    mutation updateThreadTenant($input: UpdateThreadTenantInput!) {
      updateThreadTenant(input: $input) {
        thread { #{@thread_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def mark_thread_as_done do
    """
    mutation markThreadAsDone($input: MarkThreadAsDoneInput!) {
      markThreadAsDone(input: $input) {
        thread { #{@thread_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def snooze_thread do
    """
    mutation snoozeThread($input: SnoozeThreadInput!) {
      snoozeThread(input: $input) {
        thread { #{@thread_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def mark_thread_as_todo do
    """
    mutation markThreadAsTodo($input: MarkThreadAsTodoInput!) {
      markThreadAsTodo(input: $input) {
        thread { #{@thread_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def reply_to_thread do
    """
    mutation replyToThread($input: ReplyToThreadInput!) {
      replyToThread(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def send_new_email do
    """
    mutation sendNewEmail($input: SendNewEmailInput!) {
      sendNewEmail(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def reply_to_email do
    """
    mutation replyToEmail($input: ReplyToEmailInput!) {
      replyToEmail(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def send_chat do
    """
    mutation sendChat($input: SendChatInput!) {
      sendChat(input: $input) {
        chat { #{@chat_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def send_customer_chat do
    """
    mutation sendCustomerChat($input: SendCustomerChatInput!) {
      sendCustomerChat(input: $input) {
        chat { #{@chat_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def create_note do
    """
    mutation createNote($input: CreateNoteInput!) {
      createNote(input: $input) {
        note { #{@note_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Label queries
  # ---------------------------------------------------------------------------

  @doc false
  def label_types do
    """
    query labelTypes($filters: LabelTypeFilter,
                     $first: Int, $after: String, $last: Int, $before: String) {
      labelTypes(filters: $filters,
                 first: $first, after: $after, last: $last, before: $before) {
        edges { node { #{@label_type_fields} } }
        pageInfo { #{@page_info} }
      }
    }
    """
  end

  @doc false
  def label_type_by_id do
    """
    query labelType($labelTypeId: ID!) {
      labelType(labelTypeId: $labelTypeId) { #{@label_type_fields} }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Label mutations
  # ---------------------------------------------------------------------------

  @doc false
  def add_labels do
    """
    mutation addLabels($input: AddLabelsInput!) {
      addLabels(input: $input) {
        labels { #{@label_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def remove_labels do
    """
    mutation removeLabels($input: RemoveLabelsInput!) {
      removeLabels(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def archive_label_type do
    """
    mutation archiveLabelType($input: ArchiveLabelTypeInput!) {
      archiveLabelType(input: $input) {
        labelType { #{@label_type_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def create_label_type do
    """
    mutation createLabelType($input: CreateLabelTypeInput!) {
      createLabelType(input: $input) {
        labelType { #{@label_type_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Event mutations
  # ---------------------------------------------------------------------------

  @doc false
  def create_customer_event do
    """
    mutation createCustomerEvent($input: CreateCustomerEventInput!) {
      createCustomerEvent(input: $input) {
        customerEvent { #{@customer_event_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def create_thread_event do
    """
    mutation createThreadEvent($input: CreateThreadEventInput!) {
      createThreadEvent(input: $input) {
        threadEvent { #{@thread_event_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Company queries & mutations
  # ---------------------------------------------------------------------------

  @doc false
  def companies do
    """
    query companies($first: Int, $after: String, $last: Int, $before: String) {
      companies(first: $first, after: $after, last: $last, before: $before) {
        edges { node { #{@company_fields} } }
        pageInfo { #{@page_info} }
      }
    }
    """
  end

  @doc false
  def search_companies do
    """
    query searchCompanies($searchQuery: CompaniesSearchQuery!,
                          $first: Int, $after: String, $last: Int, $before: String) {
      searchCompanies(searchQuery: $searchQuery,
                      first: $first, after: $after, last: $last, before: $before) {
        edges { node { company { #{@company_fields} } } }
        pageInfo { #{@page_info} }
      }
    }
    """
  end

  @doc false
  def upsert_company do
    """
    mutation upsertCompany($input: UpsertCompanyInput!) {
      upsertCompany(input: $input) {
        company { #{@company_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def update_company_tier do
    """
    mutation updateCompanyTier($input: UpdateCompanyTierInput!) {
      updateCompanyTier(input: $input) {
        companyTierMembership { #{@company_tier_membership_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Tenant queries & mutations
  # ---------------------------------------------------------------------------

  @doc false
  def tenants do
    """
    query tenants($first: Int, $after: String, $last: Int, $before: String) {
      tenants(first: $first, after: $after, last: $last, before: $before) {
        edges { node { #{@tenant_fields} } }
        pageInfo { #{@page_info} }
      }
    }
    """
  end

  @doc false
  def tenant_by_id do
    """
    query tenant($tenantId: ID!) {
      tenant(tenantId: $tenantId) { #{@tenant_fields} }
    }
    """
  end

  @doc false
  def search_tenants do
    """
    query searchTenants($searchQuery: TenantsSearchQuery!,
                        $first: Int, $after: String, $last: Int, $before: String) {
      searchTenants(searchQuery: $searchQuery,
                    first: $first, after: $after, last: $last, before: $before) {
        edges { node { tenant { #{@tenant_fields} } } }
        pageInfo { #{@page_info} }
      }
    }
    """
  end

  @doc false
  def upsert_tenant do
    """
    mutation upsertTenant($input: UpsertTenantInput!) {
      upsertTenant(input: $input) {
        tenant { #{@tenant_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def add_customer_to_tenants do
    """
    mutation addCustomerToTenants($input: AddCustomerToTenantsInput!) {
      addCustomerToTenants(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def remove_customer_from_tenants do
    """
    mutation removeCustomerFromTenants($input: RemoveCustomerFromTenantsInput!) {
      removeCustomerFromTenants(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def set_customer_tenants do
    """
    mutation setCustomerTenants($input: SetCustomerTenantsInput!) {
      setCustomerTenants(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def update_tenant_tier do
    """
    mutation updateTenantTier($input: UpdateTenantTierInput!) {
      updateTenantTier(input: $input) {
        tenantTierMembership { #{@tenant_tier_membership_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Tier queries & mutations
  # ---------------------------------------------------------------------------

  @doc false
  def tiers do
    """
    query tiers($first: Int, $after: String, $last: Int, $before: String) {
      tiers(first: $first, after: $after, last: $last, before: $before) {
        edges { node { #{@tier_fields} } }
        pageInfo { #{@page_info} }
      }
    }
    """
  end

  @doc false
  def tier_by_id do
    """
    query tier($tierId: ID!) {
      tier(tierId: $tierId) { #{@tier_fields} }
    }
    """
  end

  @doc false
  def add_members_to_tier do
    """
    mutation addMembersToTier($input: AddMembersToTierInput!) {
      addMembersToTier(input: $input) {
        memberships {
          __typename
          ... on TenantTierMembership { #{@tenant_tier_membership_fields} }
          ... on CompanyTierMembership { #{@company_tier_membership_fields} }
        }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def remove_members_from_tier do
    """
    mutation removeMembersFromTier($input: RemoveMembersFromTierInput!) {
      removeMembersFromTier(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # User queries
  # ---------------------------------------------------------------------------

  @doc false
  def user_by_id do
    """
    query userById($userId: ID!) {
      userById(userId: $userId) { #{@user_fields} }
    }
    """
  end

  @doc false
  def user_by_email do
    """
    query userByEmail($email: String!) {
      userByEmail(email: $email) { #{@user_fields} }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Webhook target queries & mutations
  # ---------------------------------------------------------------------------

  @doc false
  def webhook_targets do
    """
    query webhookTargets($first: Int, $after: String, $last: Int, $before: String) {
      webhookTargets(first: $first, after: $after, last: $last, before: $before) {
        edges { node { #{@webhook_target_fields} } }
        pageInfo { #{@page_info} }
      }
    }
    """
  end

  @doc false
  def webhook_target_by_id do
    """
    query webhookTarget($webhookTargetId: ID!) {
      webhookTarget(webhookTargetId: $webhookTargetId) { #{@webhook_target_fields} }
    }
    """
  end

  @doc false
  def create_webhook_target do
    """
    mutation createWebhookTarget($input: CreateWebhookTargetInput!) {
      createWebhookTarget(input: $input) {
        webhookTarget { #{@webhook_target_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def update_webhook_target do
    """
    mutation updateWebhookTarget($input: UpdateWebhookTargetInput!) {
      updateWebhookTarget(input: $input) {
        webhookTarget { #{@webhook_target_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def delete_webhook_target do
    """
    mutation deleteWebhookTarget($input: DeleteWebhookTargetInput!) {
      deleteWebhookTarget(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end

  # ---------------------------------------------------------------------------
  # Thread fields mutations
  # ---------------------------------------------------------------------------

  @doc false
  def upsert_thread_field do
    """
    mutation upsertThreadField($input: UpsertThreadFieldInput!) {
      upsertThreadField(input: $input) {
        threadField { #{@thread_field_fields} }
        error { #{@mutation_error} }
      }
    }
    """
  end

  @doc false
  def delete_thread_field do
    """
    mutation deleteThreadField($input: DeleteThreadFieldInput!) {
      deleteThreadField(input: $input) {
        error { #{@mutation_error} }
      }
    }
    """
  end
end
