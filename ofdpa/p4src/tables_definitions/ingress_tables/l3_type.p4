/*****************************************************************************/
/*                            L3 Type  flow table                            */
/*****************************************************************************/



action validate_v4_multicast() {
    bit_and(ingress_metadata.mask_l3_multicast_IPv4, ipv4.dstAddr, 0xE0000000);
    modify_field(intrinsic_metadata.l3_type_v4_hit, 1);
}

table l3_type_v4 {
    reads {
        ethernet.etherType           : exact;
        ipv4.dstAddr mask 0xE0000000 : ternary;
    }
    actions {
        validate_v4_multicast;
    }
    size : L3_TYPE_FLOW_TABLE_SIZE;
}



action validate_v6_multicast() {
    bit_and(ingress_metadata.mask_l3_multicast_IPv6, ipv6.dstAddr, 0xFF000000000000000000000000000000);
    modify_field(intrinsic_metadata.l3_type_v6_hit, 1);
}

table l3_type_v6 {
    reads {
        ethernet.etherType                                   : exact;
        ipv6.dstAddr mask 0xFF000000000000000000000000000000 : ternary;
    }
    actions {
        validate_v6_multicast;
    }
    size : L3_TYPE_FLOW_TABLE_SIZE;
}


control process_l3_type {
    apply(l3_type_v4);
    apply(l3_type_v6);


    if (intrinsic_metadata.l3_type_v4_hit == 0 and intrinsic_metadata.l3_type_v6_hit == 0 ) {
        // MISS
        process_unicast_routing();
    }
    
    if (ethernet.etherType == 0x0800 and intrinsic_metadata.l3_type_v4_hit == 1) {
        //IPv4
        if (ingress_metadata.mask_l3_multicast_IPv4 == 0xE0000000) {
            process_multicast_routing();
        } else {
            process_unicast_routing();
        }
    } else if (ethernet.etherType == 0x86dd and intrinsic_metadata.l3_type_v6_hit == 1) {
        //IPv6
        if (ingress_metadata.mask_l3_multicast_IPv6 == 0xFF000000000000000000000000000000) {
            process_multicast_routing();
        } else {
            process_unicast_routing();
        }
    }
}




