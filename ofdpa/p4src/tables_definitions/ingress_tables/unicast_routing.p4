/*****************************************************************************/
/*                             Unicast flow table                            */
/*****************************************************************************/


action unicast_routing_action() {

}

table unicast_routing {
    actions {
        unicast_routing_action;
    }
    size : UNICAST_ROUTING_FLOW_TABLE_SIZE;
}


control process_unicast_routing {
    apply(unicast_routing);
}