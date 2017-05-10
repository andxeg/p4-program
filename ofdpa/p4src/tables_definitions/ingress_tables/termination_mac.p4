
action some_action() {

}

table termination_mac {
    reads {
        standard_metadata.ingress_port  : exact;
        ethernet.etherType              : exact;
        ethernet.dstAddr                : exact;
        //vlan_vid ???
    }
    actions {
        some_action;
    }
}


control process_termination_mac {

}
