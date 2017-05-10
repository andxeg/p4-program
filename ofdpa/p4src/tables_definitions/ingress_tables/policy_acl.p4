/*****************************************************************************/
/*                           Policy ACL flow table                           */
/*****************************************************************************/


action validate_policy_acl_ipv6_vlan() {

    modify_field(intrinsic_metadata.policy_acl_ipv6_vlan_hit, 1);
}

table policy_acl_ipv6_vlan {
    reads {
        standard_metadata.ingress_port : exact;
        ethernet.etherType             : exact;
        ethernet.srcAddr               : ternary;
        ethernet.dstAddr               : ternary;
        vlan_tag_[0].vid               : ternary;
        vlan_tag_[0].pcp               : exact;
        ingress_metadata.vrf           : exact;
        ipv6.srcAddr                   : ternary;
        ipv6.dstAddr                   : ternary;
        tcp.srcPort                    : exact;
        tcp.dstPort                    : exact;
        udp.srcPort                    : exact;
        udp.dstPort                    : exact;
    }
    actions {
        validate_policy_acl_ipv6_vlan;
    }
    size : POLICY_ACL_FLOW_TABLE_SIZE;
}



action validate_policy_acl_ipv4_vlan() {

    modify_field(intrinsic_metadata.policy_acl_ipv4_vlan_hit, 1);
}

table policy_acl_ipv4_vlan {
    reads {
        standard_metadata.ingress_port : exact;
        ethernet.etherType             : exact;
        ethernet.srcAddr               : ternary;
        ethernet.dstAddr               : ternary;
        vlan_tag_[0].vid               : ternary;
        vlan_tag_[0].pcp               : exact;
        ingress_metadata.vrf           : exact;
        ipv4.srcAddr                   : ternary;
        ipv4.dstAddr                   : ternary;
        ipv4.protocol                  : exact;
        ipv4.diffserv                  : exact;
        tcp.srcPort                    : exact;
        tcp.dstPort                    : exact;
        udp.srcPort                    : exact;
        udp.dstPort                    : exact;
    }
    actions {
        validate_policy_acl_ipv4_vlan;
    }
    size : POLICY_ACL_FLOW_TABLE_SIZE;
}



control process_policy_acl {
    if (ethernet.etherType == 0x0800) {
        apply(policy_acl_ipv4_vlan);
    } else if (ethernet.etherType == 0x86dd) {
        apply(policy_acl_ipv6_vlan);
    }

    if (intrinsic_metadata.policy_acl_ipv4_vlan_hit == 0 and 
        intrinsic_metadata.policy_acl_ipv6_vlan_hit == 0) {

        process_l2_interface();
    } else {
        // MISS
    }
}

