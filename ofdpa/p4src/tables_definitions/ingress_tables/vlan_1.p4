/*****************************************************************************/
/*                              VLAN flow table                              */
/*                Implement only with inner VLAN label                       */
/*                     Inner lable is vlan_tag_[1]                           */
/*****************************************************************************/

action modify_vlan_1_tag() {

}

action pop_vlan_1_tag() {
    
}


table vlan_1 {
    reads {
        standard_metadata.ingress_port : exact;
        vlan_tag_[1].vid               : exact;
    }
    actions {
        modify_vlan_1_tag;
        pop_vlan_1_tag;
    }
    size : VLAN_1_FLOW_TABLE_SIZE;
}



control process_vlan_1 {
    apply(vlan_1);
}

