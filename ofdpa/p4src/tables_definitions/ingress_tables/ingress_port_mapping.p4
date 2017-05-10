/*****************************************************************************/
/*                     Ingress port mapping flow table                       */
/*       Actions in this table mark traffic by tunnel_id and lmep_id         */
/*****************************************************************************/


action set_port_properties(tunnel_id, lmep_id) {
    modify_field(ingress_metadata.tunnel_id, tunnel_id);
    modify_field(ingress_metadata.lmep_id, lmep_id);
}


table ingress_port_mapping {
    reads {
        standard_metadata.ingress_port : exact;
    }
    actions {
        set_port_properties;
    }
    size : INGRESS_PORT_MAPPING_FLOW_TABLE_SIZE;
}