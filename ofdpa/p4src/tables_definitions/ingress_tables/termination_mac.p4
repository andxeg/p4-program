



table termination_mac {
    reads {
        standard_metadata  : exact;
        ethernet.etherType : exact;
        ethernet.dstAddr   : exact;
        //vlan_vid ???
    }
    actions {
        
    }
}