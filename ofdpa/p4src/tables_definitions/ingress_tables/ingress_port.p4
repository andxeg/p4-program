/*****************************************************************************/
/*                         Ingress port flow table                           */
/*         Only Normal Ethernet without DSCP-IP and PCP-Ethernet.            */
/*****************************************************************************/



/* Flow mod types*/
// 1. Normal Ethernet. If tunnel_id == and lmep_id == 0 then goto VLAN. Optionaly setting VRF.
// 2. Overlay Tunnel. If tunnel_id != and lmep_id == 0 then goto Bridging.
//    Implemented in control process_ingress_port


 /* Built-in flow mods */
// 1. "Built-in Normal Ethernet VLAN". If tunnel_id == and lmep_id == 0 then goto VLAN
// In fact normal_ethernet_not_set_vrf implement this flow mod.

// 2. "Table miss". Match is empty, goto POLICY_ACL
// It are implemented in control ingress.


action normal_ethernet_set_vrf(vrf) {
    modify_field(intrinsic_metadata.ingress_port_hit, 1);
    modify_field(ingress_metadata.vrf, vrf);
}

action normal_ethernet_not_set_vrf() {
    modify_field(intrinsic_metadata.ingress_port_hit, 1);
}

table ingress_port {
    reads {
        standard_metadata.ingress_port : exact;
        ingress_metadata.tunnel_id     : exact;
        ingress_metadata.lmep_id       : exact;        
    }
    actions {
        // optionaly set VRF
        
        normal_ethernet_set_vrf;
        normal_ethernet_not_set_vrf;

       
    }
    size : INGRESS_PORT_FLOW_TABLE_SIZE;
}

control process_ingress_port {    
    #ifndef INGRESS_PORT_MAPPING_DISABLE 
        apply(ingress_port_mapping);
    #endif

    if (ingress_metadata.tunnel_id == 0 and ingress_metadata.lmep_id == 0) {
        apply(ingress_port);
        if (intrinsic_metadata.ingress_port_hit == 1) {
            // HIT
            process_vlan();
        } else {
            // MISS
            // Policy ACL is a penultimate table;
            // L2 Interface is the last table 
            // and it is a group table.
            process_policy_acl();
        }
    } else if (ingress_metadata.tunnel_id != 0 and ingress_metadata.lmep_id == 0) {
        // It is Tunnel overlay flow mod
        // GOTO Bridging Flow Table
        process_bridging();
    }    
}
