/*****************************************************************************/
/*                      Termination MAC flow table                           */
/*****************************************************************************/



action validate_l2_multicast() {
    bit_and(ingress_metadata.mask_l2_multicast_IPv4, ethernet.dstAddr, 0xffffff800000);
    bit_and(ingress_metadata.mask_l2_multicast_IPv6, ethernet.dstAddr, 0xffff00000000);
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
        validate_l2_multicast;
    }
}


control process_termination_mac {
    apply(termination_mac);

    if (intrinsic_metadata.termination_mac_hit == 1) {
        if (ethernet.etherType == 0x0800) {
            //IPv4
            if (ingress_metadata.mask_l2_multicast_IPv4 == 0x01005e000000) {
                // IPv4 Multicast MAC
                process_multicast_routing();
            } else {
                // IPv4 Unicast MAC
                process_l3_type();
            }
        } else if (ethernet.etherType == 0x86dd) {
            //IPv6
            if (ingress_metadata.mask_l2_multicast_IPv6 == 0x333300000000) {
                // IPv6 Multicast MAC
                process_multicast_routing();
            } else {
                // IPv4 Unicast MAC
                process_l3_type();
            }
        }
    } else {
        // MISS
        process_bridging();
    }
}
