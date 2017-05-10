/*****************************************************************************/
/*                              Intrinsic Metadata                           */
/*****************************************************************************/


header_type intrinsic_metadata_t {
    fields {
        
        ingress_port_hit         : 1;
        ingress_port_set_vrf     : 1;
        ingress_port_not_set_vrf : 1;
        
        vlan_modify_vlan_tag     : 1;
        vlan_pop_vlan_tag        : 1;
        vlan_pass                : 1;

        vlan_1_hit               : 1;
        vlan_1_modify_vlan_1_tag : 1;
        vlan_1_pop_vlan_1_tag    : 1;

        vlan_2_hit               : 1;

        termination_mac_hit      : 1;

        l3_type_v4_hit           : 1;
        l3_type_v6_hit           : 1;
                    
    }
}

