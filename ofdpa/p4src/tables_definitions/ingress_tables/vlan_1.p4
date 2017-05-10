/*****************************************************************************/
/*                            VLAN 1 flow table                              */
/*                Implement only with inner VLAN label                       */
/*                     Inner lable is vlan_tag_[1]                           */
/*****************************************************************************/


action modify_vlan_1_tag(vid) {
    modify_field(vlan_tag_[1].vid, vid);        
    modify_field(intrinsic_metadata.vlan_1_hit, 1);
}


action pop_vlan_1_tag() {
    modify_field(ethernet.etherType, vlan_tag_[1].etherType);
    remove_header(vlan_tag_[1]);
    modify_field(intrinsic_metadata.vlan_1_hit, 1);
}


action push_vlan_1_tag(vid) {
    // Add second label
    modify_field(ethernet.etherType, ETHERTYPE_QINQ);
    add_header(vlan_tag_[0]);
    modify_field(vlan_tag_[0].etherType, ETHERTYPE_ONE_VLAN);
    modify_field(vlan_tag_[0].vid, vid);
    modify_field(intrinsic_metadata.vlan_1_hit, 1);
}


action modify_vlan_1_tag_and_push_vlan_tag(vid_inner, vid_outer) {
    modify_field(vlan_tag_[1].vid, vid_inner);
    modify_field(ethernet.etherType, ETHERTYPE_QINQ);
    add_header(vlan_tag_[0]);
    modify_field(vlan_tag_[0].etherType, ETHERTYPE_ONE_VLAN);
    modify_field(vlan_tag_[0].vid, vid_outer);
    modify_field(intrinsic_metadata.vlan_1_hit, 1);
}


table vlan_1 {
    reads {
        standard_metadata.ingress_port : exact;
        vlan_tag_[1].vid               : exact;
    }
    actions {
        // optionaly set VRF

        modify_vlan_1_tag;
        pop_vlan_1_tag;
        push_vlan_1_tag;
        modify_vlan_1_tag_and_push_vlan_tag;
    }
    size : VLAN_1_FLOW_TABLE_SIZE;
}


control process_vlan_1 {
    // Now only one label in packet
    // This label is vlan_tag_[1]

    apply(vlan_1);
    if (intrinsic_metadata.vlan_1_hit == 1) {
        // HIT
        process_termination_mac();
    } else {
        // MISS
        process_policy_acl();
    }
}

