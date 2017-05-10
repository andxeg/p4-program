/*****************************************************************************/
/*                             Unicast flow table                            */
/*****************************************************************************/


action pass_unicast_routing_ipv4() {
    modify_field(intrinsic_metadata.unicast_routing_ipv4_hit, 1);
}

table unicast_routing_ipv4 {
    reads {
        ethernet.etherType   : exact;
        ipv4.dstAddr         : lpm;
        ingress_metadata.vrf : exact;
    }
    actions {
        pass_unicast_routing_ipv4;
    }
    size : UNICAST_ROUTING_FLOW_TABLE_SIZE;
}



action pass_unicast_routing_ipv6() {
    modify_field(intrinsic_metadata.unicast_routing_ipv6_hit, 1);
}

table unicast_routing_ipv6 {
    reads {
        ethernet.etherType   : exact;
        ipv6.dstAddr         : lpm;
        ingress_metadata.vrf : exact;
    }
    actions {
        pass_unicast_routing_ipv6;
    }
    size : UNICAST_ROUTING_FLOW_TABLE_SIZE;
}


control process_unicast_routing {
    apply(unicast_routing_ipv4);
    apply(unicast_routing_ipv6);
    
    process_policy_acl();
}
