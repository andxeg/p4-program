/*****************************************************************************/
/*                            Bridging flow table                            */
/*****************************************************************************/


action validate_dlf_vlan() {
    modify_field(intrinsic_metadata.dlf_vlan_hit, 1);
}

table dlf_vlan {
    reads {
        vlan_tag_[0].vid : exact;
    }
    actions {
        validate_dlf_vlan;
    }
    size : BRIDGING_FLOW_TABLE_SIZE;
}



action validate_unicast_overlay() {
    modify_field(intrinsic_metadata.unicast_overlay_hit, 1);
}

table unicast_overlay() {
    reads {
        ethernet.dstAddr mask 0x010000000000 : exact;
        ingress_metadate.tunnel_id           : exact;
    }
    actions {
        validate_unicast_overlay;
    }
    size : BRIDGING_FLOW_TABLE_SIZE;
}




action bridging_action() {
    bit_and(ingress_metadata.mask_l2_for_vlan_cast, ethernet.dstAddr, 0x010000000000);
    modify_field(intrinsic_metadata.bridging_hit, 1);
}


table bridging {
    reads {
        ethernet.dstAddr mask 0x010000000000 : exact;
        vlan_tag_[0].vid                     : exact;
    }
    actions {
        bridging_action;
    }
    size : BRIDGING_FLOW_TABLE_SIZE;
}


control process_bridging {
    apply(unicast_overlay)
    apply(dlf_vlan)
    apply(bridging);

    if (intrinsic_metadata.bridging_hit == 1) {

        if (ingress_metadata.mask_l2_for_vlan_cast == 0x000000000000) {
            // Unicast VLAN
            process_policy_acl();
        } else if (ingress_metadata.mask_l2_for_vlan_cast == 0x010000000000) {
            // Multicast VLAN
            process_policy_acl();
        }
    } else {
        // MISS
        process_policy_acl();
    }
}
