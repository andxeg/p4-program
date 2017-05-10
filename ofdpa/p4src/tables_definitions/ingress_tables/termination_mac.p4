/*****************************************************************************/
/*                      Termination MAC flow table                           */
/*****************************************************************************/



action validate_multicast() {
    bit_and(ingress_metadata.mask_multicast_IPv4, ethernet.dstAddr, 0xffffff800000);
    bit_and(ingress_metadata.mask_multicast_IPv6, ethernet.dstAddr, 0xffff00000000);
    modify_field(intrinsic_metadata.termination_mac_hit, 1);
}

table termination_mac {
    reads {
        standard_metadata.ingress_port  : exact;
        ethernet.etherType              : exact;
        ethernet.dstAddr                : exact;
        vlan_tag_[0]                    : exact;
    }
    actions {
        validate_multicast;
    }
}


control process_termination_mac {
    apply(termination_mac);

    if (intrinsic_metadata.termination_mac_hit == 1) {
        if (ethernet.etherType == 0x0800) {
            
            if (ingress_metadata.mask_multicast_IPv4 == 0x01005e000000) {
                process_multicast_routing();
            } else {
                // IPv4 Unicast MAC
                // exactly one
                // process_l3_type();
                // process_unicast_routing();
            }
        } else if (ethernet.etherType == 0x86dd) {
            if (ingress_metadata.mask_multicast_IPv6 == 0x333300000000) {
                process_multicast_routing();
            } else {
                // IPv4 Unicast MAC
                // exactly one
                // process_l3_type();
                // process_unicast_routing();
            }
        }
    } else {
        process_bridging();
    }
}
