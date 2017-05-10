/*****************************************************************************/
/*                              VLAN flow table                              */
/*                Implement only with outer VLAN label                       */
/*                     Outer lable is vlan_tag_[0]                           */
/*****************************************************************************/


header_type vlan_tag_t {
    fields {
        pcp : 3;
        cfi : 1;
        vid : 12;
        etherType : 16;
    }
}


action modify_vlan_tag(vid) {
    modify_field(vlan_tag_[0].vid, vid);
    modify_field(intrinsic_metadata.vlan_modify_vlan_tag, 1);
}

action pop_vlan_tag() {
    modify_field(ethernet.etherType, vlan_tag_[0].etherType);
    remove_header(vlan_tag_[0]);
    modify_field(intrinsic_metadata.vlan_pop_vlan_tag, 1);
}


action pass() {
    modify_field(intrinsic_metadata.vlan_pass, 1);
}

table vlan {
    reads {
        standard_metadata.ingress_port : exact;
        vlan_tag_[0].vid               : exact;
    }
    actions {
        // optionaly set VRF

        modify_vlan_tag;
        pop_vlan_tag;
        pass;
    }
    size : VLAN_FLOW_TABLE_SIZE;
}



control process_vlan {
    // Check vlan labels.
    // You must check existence of VLAN labels.
    // If vlan_tag_[1] is existed then vlan_tag_[0] is also existed.

    if (valid(vlan_tag_[0]) and valid(vlan_tag_[1])) {
        // process outer vlan label in double tagged packet
        apply(vlan);
        
        if (intrinsic_metadata.vlan_pop_vlan_tag == 1) {
            // vlan_tag_[0]) is invalid now
            // If label was popped.
            process_vlan_1();
        } else if (intrinsic_metadata.vlan_modify_vlan_tag == 1) {
            // If label was modified
            process_termination_mac();
        } else {
            // MISS
            process_policy_acl();
        }

    } else if ( not valid(vlan_tag_[1]) and  valid(vlan_tag_[0]) ) {
        // process outer vlan label in single tagged packet
        apply(vlan);
        
        if (intrinsic_metadata.vlan_pop_vlan_tag == 1) {
            // vlan_tag_[0]) is invalid now
            // If label was popped.
            process_termination_mac();
        } else if (intrinsic_metadata.vlan_modify_vlan_tag == 1 or 
                   intrinsic_metadata.vlan_pass) {
            // If label was modified
            // If I want to add new tag to packet
            // It s required a new table, because Vlan 1 work with vlan_tag_[1]
            // Vlan Flow Table has another semantic.
            process_vlan_2();
        } else {
            // MISS
            process_policy_acl();
        }
    }
    
    // If packet hasn't labels then goto next table in pipeline
}
