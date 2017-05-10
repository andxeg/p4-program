/*****************************************************************************/
/*                           Multicast flow table                            */
/*****************************************************************************/

 action validate_v4() {
    modify_field(intrinsic_metadata.multicast_routing_ipv4_hit, 1);
 }


table multicast_routing_ipv4 {
    reads {
        ethernet.etherType           : exact;
        ipv4.dstAddr mask 0xE0000000 : ternary;
        ipv4.srcAddr                 : exact;
        vlan_tag_[0].vid             : exact;
        ingress_metadata.vrf         : exact;
    }
    actions {
        validate_v4;
    }
    size : MULTICAST_ROUTING_FLOW_TABLE_SIZE;
}


action validate_v6() {
     modify_field(intrinsic_metadata.multicast_routing_ipv6_hit, 1);
 }

table multicast_routing_ipv6 {
    reads {
        ethernet.etherType                                   : exact;
        ipv6.dstAddr mask 0xFF000000000000000000000000000000 : ternary;
        ipv6.srcAddr                                         : exact;
        vlan_tag_[0]                                         : exact;
        ingress_metadata.vrf                                 : exact;
    }
    actions {
        validate_v6;
    }
    size : MULTICAST_ROUTING_FLOW_TABLE_SIZE;
}


control process_multicast_routing {
    apply(multicast_routing_ipv4);
    apply(multicast_routing_ipv6);

    process_policy_acl();
}