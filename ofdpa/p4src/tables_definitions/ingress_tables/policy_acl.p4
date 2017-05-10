

action policy_acl_action() {

}

table policy_acl {
    actions {
        policy_acl_action;
    }
    size : POLICY_ACL_FLOW_TABLE_SIZE;
}

control process_policy_acl {
    apply(policy_acl);
}

