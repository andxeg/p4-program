// This is P4 sample source for ofdpa
// Fill in these files with your P4 code

#include "includes/headers.p4"
#include "includes/parser.p4"
#include "includes/defines.p4"



/* METADATA */
header_type ingress_metadata_t {
    fields {
        ingress_port : 9;                      /* input physical port */
        ifindex : IFINDEX_BIT_WIDTH;           /* input interface index */
        egress_ifindex : IFINDEX_BIT_WIDTH;    /* egress interface index */
        port_type : 2;                         /* ingress port type */

        outer_bd : BD_BIT_WIDTH;               /* outer BD */
        bd : BD_BIT_WIDTH;                     /* BD */

        drop_flag : 1;                         /* if set, drop the packet */
        drop_reason : 8;                       /* drop reason */
        control_frame: 1;                      /* control frame */
        bypass_lookups : 16;                   /* list of lookups to skip */
        sflow_take_sample : 32 (saturating);
    }
}

header_type egress_metadata_t {
    fields {
        bypass : 1;                            /* bypass egress pipeline */
        port_type : 2;                         /* egress port type */
        payload_length : 16;                   /* payload length for tunnels */
        smac_idx : 9;                          /* index into source mac table */
        bd : BD_BIT_WIDTH;                     /* egress inner bd */
        outer_bd : BD_BIT_WIDTH;               /* egress inner bd */
        mac_da : 48;                           /* final mac da */
        routed : 1;                            /* is this replica routed */
        same_bd_check : BD_BIT_WIDTH;          /* ingress bd xor egress bd */
        drop_reason : 8;                       /* drop reason */
        ifindex : IFINDEX_BIT_WIDTH;           /* egress interface index */
    }
}

metadata ingress_metadata_t ingress_metadata;
metadata egress_metadata_t egress_metadata;


#include "l3.p4"


action nop() {
}

action on_miss() {
}

action _drop() {
    drop();
}


// action set_egr(egress_spec) {
//     modify_field(standard_metadata.egress_spec, egress_spec);
// }

// table forward {
//     reads {
//         ethernet.dstAddr : exact;
//     }
//     actions {
//         set_egr;
//     }
// }

// table acl {
//     reads {
//         ethernet.dstAddr : ternary;
//         ethernet.srcAddr : ternary;
//     }
//     actions {
//         _drop;
//     }
// }

// control ingress {
//     apply(forward);
// }

// control egress {
//     apply(acl);
// }


header_type routing_metadata_t {
    fields {
        nhop_ipv4 : 32;
    }
}

metadata routing_metadata_t routing_metadata;

action set_nhop(nhop_ipv4, port) {
    modify_field(routing_metadata.nhop_ipv4, nhop_ipv4);
    modify_field(standard_metadata.egress_spec, port);
    add_to_field(ipv4.ttl, -1);
}

table ipv4_lpm {
    reads {
        ipv4.dstAddr : lpm;
    }
    actions {
        set_nhop;
        _drop;
    }
    size: 1024;
}

action set_dmac(dmac) {
    modify_field(ethernet.dstAddr, dmac);
}

table forward {
    reads {
        routing_metadata.nhop_ipv4 : exact;
    }
    actions {
        set_dmac;
        _drop;
    }
    size: 512;
}

action rewrite_mac(smac) {
    modify_field(ethernet.srcAddr, smac);
}

table send_frame {
    reads {
        standard_metadata.egress_port: exact;
    }
    actions {
        rewrite_mac;
        _drop;
    }
    size: 256;
}

control ingress {
    apply(ipv4_lpm);
    apply(forward);
}

control egress {
    apply(send_frame);
}



