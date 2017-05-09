/*****************************************************************************/
/*                         Ingress port flow table                           */
/*         Only Normal Ethernet without DSCP-IP and PCP-Ethernet.            */
/*****************************************************************************/


// action normal_ethernet() {
// match:
//     in_port       , all_or_exact
//     tunnel_id == 0, exact
//     lmep_id   == 0, exact

// actions:
//     goto VLAN
//     set one_or_not vrf
// }

action normal_ethernet_set_vrf(vrf) {
    modify_field(ingress_metadata.vrf, vrf);
}

action normal_ethernet_not_set_vrf() {
}

table ingress_port {
    reads {
        standard_metadata.ingress_port : exact;
        ingress_metadata.tunnel_id     : exact;
        ingress_metadata.lmep_id       : exact;        
    }
    actions {
        normal_ethernet_set_vrf;
        normal_ethernet_not_set_vrf;

        /* Built_in flow mods */
        // 1. "Built-in Normal Ethernet VLAN". If tunnel_id == and lmep_id == 0 then goto VLAN
        // In fact normal_ethernet_not_set_vrf implement this flow mod.

        // 2. "Table miss". Match is empty, goto POLICY_ACL
        // It are implemented in control ingress.
    }
    size : INGRESS_PORT_FLOW_TABLE_SIZE;
}
