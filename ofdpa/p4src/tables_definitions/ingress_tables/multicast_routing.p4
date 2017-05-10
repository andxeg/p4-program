/*****************************************************************************/
/*                           Multicast flow table                            */
/*****************************************************************************/


action multicast_action() {

}

table multicast_routing {
    actions {
        multicast_action;
    }
    size : MULTICAST_ROUTING_FLOW_TABLE_SIZE;
}


control process_multicast_routing {
    apply(multicast_routing);
}